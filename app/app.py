import pyodbc
from flask import Flask, render_template

app = Flask(__name__)

def get_db_connection():
    # Switch to 'ActiveDirectoryFederated' for AKS Workload Identity
    conn_str = (
        "Driver={ODBC Driver 18 for SQL Server};"
        "Server=sql-server-aviator-maintenance.database.windows.net,1433;"
        "Database=db-airplane-maintenance;"
        "UID=58737ab5-dd13-4381-b28e-82d46e297800;" # Matches your authorized Identity
        "Authentication=ActiveDirectoryFederated;" # Correct method for Workload Identity
        "Encrypt=yes;"
        "TrustServerCertificate=yes;" # Set to 'yes' to bypass local SSL handshake issues
    )
    return pyodbc.connect(conn_str)

@app.route('/')
def index():
    try:
        conn = get_db_connection()
        cursor = conn.cursor()
        # Fetching your 280 verified records
        cursor.execute("SELECT LogID, TailNumber, Status, Component, PartHours, Details, InspectionDate FROM dbo.MaintenanceLogs")
        rows = cursor.fetchall()
        conn.close()
        return render_template('index.html', rows=rows)
    except Exception as e:
        print(f"!!! NEW STRATEGY FAILURE: {str(e)}")
        return f"Database Error: {str(e)}", 500
