"""
JetOps SQL Explorer — MCP server for ad hoc, read-only SQL exploration
against the Aviator Core maintenance database.

Exposes three tools over the streamable-http MCP transport:
  - list_tables():                enumerate tables in the database
  - describe_table(table, schema): list a table's columns and types
  - run_query(sql, max_rows):     run a SELECT-only ad hoc query

Connects via JETOPS_SQL_CONNECTION_STRING, same env var used by the
legacy dashboard route in app/app.py.
"""
import os
import re

import pyodbc
from mcp.server.fastmcp import FastMCP

CONN_STR = os.environ.get("JETOPS_SQL_CONNECTION_STRING")
MAX_ROWS = 200

mcp = FastMCP("jetops-sql-explorer", host="0.0.0.0", port=8080)

_DISALLOWED = re.compile(
    r"\b(insert|update|delete|drop|alter|truncate|merge|exec|execute|grant|revoke|create)\b",
    re.IGNORECASE,
)
_SELECT_START = re.compile(r"(?is)^\s*(with\b.*?)?select\b")


def _connect():
    if not CONN_STR:
        raise RuntimeError("JETOPS_SQL_CONNECTION_STRING is not configured for this server.")
    return pyodbc.connect(CONN_STR)


def _rows_to_dicts(cursor, limit):
    columns = [col[0] for col in cursor.description]
    rows = cursor.fetchmany(limit)
    return [dict(zip(columns, row)) for row in rows]


@mcp.tool()
def list_tables() -> list[dict]:
    """List tables available in the database, with schema and table name."""
    with _connect() as conn:
        cursor = conn.cursor()
        cursor.execute(
            "SELECT TABLE_SCHEMA, TABLE_NAME FROM INFORMATION_SCHEMA.TABLES "
            "WHERE TABLE_TYPE = 'BASE TABLE' ORDER BY TABLE_SCHEMA, TABLE_NAME"
        )
        return _rows_to_dicts(cursor, 500)


@mcp.tool()
def describe_table(table_name: str, schema: str = "dbo") -> list[dict]:
    """List columns, data types, and nullability for a table."""
    with _connect() as conn:
        cursor = conn.cursor()
        cursor.execute(
            "SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE, CHARACTER_MAXIMUM_LENGTH "
            "FROM INFORMATION_SCHEMA.COLUMNS "
            "WHERE TABLE_SCHEMA = ? AND TABLE_NAME = ? ORDER BY ORDINAL_POSITION",
            schema,
            table_name,
        )
        return _rows_to_dicts(cursor, 500)


@mcp.tool()
def run_query(sql: str, max_rows: int = 100) -> dict:
    """
    Run a read-only, ad hoc SQL query against the JetOps maintenance
    database and return up to max_rows rows. Only SELECT statements
    (optionally with a leading WITH clause) are permitted; a single
    statement only, no semicolon-separated batches.
    """
    stripped = sql.strip().rstrip(";")
    if not _SELECT_START.match(stripped):
        raise ValueError("Only SELECT statements (optionally starting with a WITH clause) are allowed.")
    if _DISALLOWED.search(stripped):
        raise ValueError("Query contains a disallowed keyword; only read-only SELECT queries are permitted.")
    if ";" in stripped:
        raise ValueError("Multiple statements are not allowed.")

    limit = max(1, min(max_rows, MAX_ROWS))
    with _connect() as conn:
        cursor = conn.cursor()
        cursor.execute(stripped)
        rows = _rows_to_dicts(cursor, limit)
        return {"row_count": len(rows), "rows": rows}


if __name__ == "__main__":
    mcp.run(transport="streamable-http")
