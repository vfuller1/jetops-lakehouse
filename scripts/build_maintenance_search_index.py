"""
Build an Azure AI Search vector index over JetOps maintenance log history.

Source data: app/maintenance_logs_sample_data.sql (MaintenanceLogs table).
Embeddings:  text-embedding-3-small, via the Foundry project's Azure OpenAI connection.
Index:       hybrid keyword + vector search over each maintenance log entry.

Usage:
    az login
    $env:AZURE_SEARCH_ENDPOINT = "https://srch-herbalife-dev.search.windows.net"
    $env:AZURE_SEARCH_KEY = "<admin key>"
    python scripts/build_maintenance_search_index.py
"""
import os
import re
import time

from azure.ai.projects import AIProjectClient
from azure.identity import AzureCliCredential
from azure.core.credentials import AzureKeyCredential
from azure.search.documents import SearchClient
from azure.search.documents.indexes import SearchIndexClient
from azure.search.documents.indexes.models import (
    SearchIndex,
    SearchField,
    SearchFieldDataType,
    SimpleField,
    SearchableField,
    VectorSearch,
    VectorSearchProfile,
    HnswAlgorithmConfiguration,
)

PROJECT_ENDPOINT = "https://jetops-foundry-dev-41497b8e.services.ai.azure.com/api/projects/fleet-maintenance-copilot"
EMBEDDING_MODEL = "text-embedding-3-small"
EMBEDDING_DIMENSIONS = 1536
INDEX_NAME = "jetops-maintenance-history"
SQL_PATH = os.path.join(os.path.dirname(__file__), "..", "app", "maintenance_logs_sample_data.sql")

INSERT_PATTERN = re.compile(
    r"INSERT INTO dbo\.MaintenanceLogs \([^)]*\) VALUES \("
    r"(\d+),\s*'([^']*)',\s*'([^']*)',\s*'([^']*)',\s*(\d+),\s*'([^']*)',\s*'([^']*)'\)"
)


def load_records():
    with open(SQL_PATH, "r", encoding="utf-8") as f:
        sql = f.read()
    records = []
    for log_id, tail_number, status, component, part_hours, details, inspection_date in INSERT_PATTERN.findall(sql):
        records.append({
            "log_id": log_id,
            "tail_number": tail_number,
            "status": status,
            "component": component,
            "part_hours": int(part_hours),
            "inspection_date": inspection_date,
            "content": f"{tail_number} ({status}, {component}): {details} Inspected {inspection_date}.",
        })
    return records


def ensure_index(index_client: SearchIndexClient):
    fields = [
        SimpleField(name="log_id", type=SearchFieldDataType.String, key=True),
        SearchableField(name="tail_number", type=SearchFieldDataType.String, filterable=True),
        SearchableField(name="status", type=SearchFieldDataType.String, filterable=True),
        SearchableField(name="component", type=SearchFieldDataType.String, filterable=True),
        SimpleField(name="part_hours", type=SearchFieldDataType.Int32, filterable=True, sortable=True),
        SimpleField(name="inspection_date", type=SearchFieldDataType.String, filterable=True, sortable=True),
        SearchableField(name="content", type=SearchFieldDataType.String),
        SearchField(
            name="content_vector",
            type=SearchFieldDataType.Collection(SearchFieldDataType.Single),
            searchable=True,
            vector_search_dimensions=EMBEDDING_DIMENSIONS,
            vector_search_profile_name="maintenance-vector-profile",
        ),
    ]
    vector_search = VectorSearch(
        algorithms=[HnswAlgorithmConfiguration(name="maintenance-hnsw")],
        profiles=[VectorSearchProfile(name="maintenance-vector-profile", algorithm_configuration_name="maintenance-hnsw")],
    )
    index_client.create_or_update_index(SearchIndex(name=INDEX_NAME, fields=fields, vector_search=vector_search))


def main():
    search_endpoint = os.environ["AZURE_SEARCH_ENDPOINT"]
    search_key = os.environ["AZURE_SEARCH_KEY"]
    search_credential = AzureKeyCredential(search_key)

    records = load_records()
    print(f"Loaded {len(records)} maintenance log records from {SQL_PATH}")

    project = AIProjectClient(endpoint=PROJECT_ENDPOINT, credential=AzureCliCredential())
    openai_client = project.get_openai_client(api_version="2024-10-21")

    batch_size = 5
    for start in range(0, len(records), batch_size):
        batch = records[start:start + batch_size]
        embeddings = openai_client.embeddings.create(
            model=EMBEDDING_MODEL,
            input=[r["content"] for r in batch],
        )
        for record, embedding in zip(batch, embeddings.data):
            record["content_vector"] = embedding.embedding
        print(f"Embedded {start + len(batch)}/{len(records)} records")
        if start + batch_size < len(records):
            time.sleep(10)

    index_client = SearchIndexClient(endpoint=search_endpoint, credential=search_credential)
    ensure_index(index_client)
    print(f"Index '{INDEX_NAME}' ready.")

    search_client = SearchClient(endpoint=search_endpoint, index_name=INDEX_NAME, credential=search_credential)
    result = search_client.upload_documents(documents=records)
    failed = [r for r in result if not r.succeeded]
    print(f"Uploaded {len(result) - len(failed)}/{len(result)} documents.")
    if failed:
        for f in failed:
            print(f"  FAILED {f.key}: {f.error_message}")


if __name__ == "__main__":
    main()
