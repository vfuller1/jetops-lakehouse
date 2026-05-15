"""
smoke_test_adls_foundry.py
--------------------------
End-to-end smoke test for:
  1. ADLS Gen2  – can the Gold KPI service reach all four snapshot directories?
  2. Gold KPI API – are all six protected endpoints reachable and returning data?
  3. Azure AI Foundry – can the fleet-maintenance-copilot agent answer a simple triage question?

Required environment variables
-------------------------------
  JETOPS_API_KEY                 API key for the Gold KPI Flask API  (x-api-key header)

Optional environment variables (defaults shown)
-----------------------------------------------
  JETOPS_STORAGE_ACCOUNT         stherbalifedev001
  JETOPS_RESOURCE_GROUP          rg-herbalife-dev-core
  JETOPS_GOLD_CONTAINER          gold
  JETOPS_GOLD_API_SNAPSHOT_ROOT  jetops/maintenance_kpis_api
  JETOPS_STORAGE_ACCOUNT_KEY     (resolved from az CLI if not set)
  JETOPS_GOLD_API_BASE_URL       https://jetops-gold-api.blackpebble-8c1a9729.eastus2.azurecontainerapps.io
  JETOPS_FOUNDRY_ENDPOINT        https://jetops-foundry-dev-41497b8e.services.ai.azure.com/api/projects/fleet-maintenance-copilot
  JETOPS_FOUNDRY_AGENT_NAME      fleet-maintenance-copilot-agent
  JETOPS_FOUNDRY_MODEL           gpt-4-1-mini

Usage
-----
  # Minimal – skips Foundry if az login not done
  JETOPS_API_KEY=<key> python scripts/smoke_test_adls_foundry.py

  # Full – all three layers
  az login
  JETOPS_API_KEY=<key> python scripts/smoke_test_adls_foundry.py
"""

import os
import shutil
import subprocess
import sys
import textwrap
from pathlib import Path

import requests

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------

PASS = "\u2713"
FAIL = "\u2717"
SKIP = "-"

_results: list[tuple[str, bool | None, str]] = []  # (label, passed, detail)


def _record(label: str, passed: bool | None, detail: str = "") -> None:
    _results.append((label, passed, detail))
    icon = PASS if passed is True else (SKIP if passed is None else FAIL)
    print(f"  [{icon}] {label}")
    if detail:
        for line in textwrap.wrap(detail, width=100, initial_indent="       ", subsequent_indent="       "):
            print(line)


def _section(title: str) -> None:
    print(f"\n{'='*60}")
    print(f"  {title}")
    print(f"{'='*60}")


def _summary() -> None:
    _section("SUMMARY")
    passed = sum(1 for _, p, _ in _results if p is True)
    failed = sum(1 for _, p, _ in _results if p is False)
    skipped = sum(1 for _, p, _ in _results if p is None)
    for label, p, detail in _results:
        icon = PASS if p is True else (SKIP if p is None else FAIL)
        print(f"  [{icon}] {label}")
    print(f"\n  Passed: {passed}  Failed: {failed}  Skipped: {skipped}")
    if failed:
        print("\n  One or more checks failed. See details above.")
        sys.exit(1)
    print("\n  All checks passed.")


# ---------------------------------------------------------------------------
# Env / config
# ---------------------------------------------------------------------------

STORAGE_ACCOUNT = os.getenv("JETOPS_STORAGE_ACCOUNT", "stherbalifedev001")
RESOURCE_GROUP = os.getenv("JETOPS_RESOURCE_GROUP", "rg-herbalife-dev-core")
GOLD_CONTAINER = os.getenv("JETOPS_GOLD_CONTAINER", "gold")
SNAPSHOT_ROOT = os.getenv("JETOPS_GOLD_API_SNAPSHOT_ROOT", "jetops/maintenance_kpis_api")
API_KEY = os.getenv("JETOPS_API_KEY", "")

GOLD_API_BASE = os.getenv(
    "JETOPS_GOLD_API_BASE_URL",
    "https://jetops-gold-api.blackpebble-8c1a9729.eastus2.azurecontainerapps.io",
).rstrip("/")

FOUNDRY_ENDPOINT = os.getenv(
    "JETOPS_FOUNDRY_ENDPOINT",
    "https://jetops-foundry-dev-41497b8e.services.ai.azure.com/api/projects/fleet-maintenance-copilot",
)
FOUNDRY_AGENT_NAME = os.getenv("JETOPS_FOUNDRY_AGENT_NAME", "fleet-maintenance-copilot-agent")
FOUNDRY_MODEL = os.getenv("JETOPS_FOUNDRY_MODEL", "gpt-4-1-mini")

SNAPSHOTS = ["executive_kpis", "daily_operations", "component_reliability", "fleet_status_snapshot"]

GOLD_API_ENDPOINTS = [
    ("/api/gold/health",                      None,         "health"),
    ("/api/gold/metadata",                    None,         "metadata"),
    ("/api/gold/openapi.json",                None,         "openapi"),
    ("/api/gold/kpis/executive",              None,         "executive KPIs"),
    ("/api/gold/kpis/daily-operations",       {"days": 14}, "daily operations"),
    ("/api/gold/kpis/component-reliability",  {"days": 7, "limit": 10}, "component reliability"),
    ("/api/gold/kpis/fleet-watchlist",        {"limit": 10}, "fleet watchlist"),
]

FOUNDRY_TEST_QUESTION = (
    "How many aircraft currently have critical issues? "
    "Use the maintenance KPI API and give a one-sentence answer."
)


# ---------------------------------------------------------------------------
# Layer 1: ADLS Gen2
# ---------------------------------------------------------------------------

def _resolve_storage_key() -> str:
    explicit = os.getenv("JETOPS_STORAGE_ACCOUNT_KEY")
    if explicit:
        return explicit

    az_cmd = os.getenv(
        "AZURE_CLI_PATH",
        r"C:\Program Files\Microsoft SDKs\Azure\CLI2\wbin\az.cmd",
    )
    if not Path(az_cmd).exists():
        az_cmd = shutil.which("az") or ""

    if not az_cmd:
        raise RuntimeError(
            "JETOPS_STORAGE_ACCOUNT_KEY is not set and 'az' CLI was not found. "
            "Either set the env var or run 'az login' first."
        )

    return subprocess.check_output(
        [
            az_cmd, "storage", "account", "keys", "list",
            "--resource-group", RESOURCE_GROUP,
            "--account-name", STORAGE_ACCOUNT,
            "--query", "[0].value",
            "-o", "tsv",
        ],
        text=True,
    ).strip()


def test_adls() -> None:
    _section("Layer 1 – ADLS Gen2 Gold Snapshots")

    try:
        from azure.storage.filedatalake import DataLakeServiceClient
    except ImportError:
        _record("azure-storage-file-datalake installed", False,
                "Run: pip install azure-storage-file-datalake")
        return

    # Resolve key
    try:
        key = _resolve_storage_key()
        _record("Storage account key resolved", True)
    except Exception as exc:
        _record("Storage account key resolved", False, str(exc))
        return

    # Connect
    try:
        conn_str = (
            f"DefaultEndpointsProtocol=https;AccountName={STORAGE_ACCOUNT};"
            f"AccountKey={key};EndpointSuffix=core.windows.net"
        )
        client = DataLakeServiceClient.from_connection_string(conn_str)
        fs = client.get_file_system_client(GOLD_CONTAINER)
        _record(f"Connected to storage account '{STORAGE_ACCOUNT}' / container '{GOLD_CONTAINER}'", True)
    except Exception as exc:
        _record(f"Connected to storage account '{STORAGE_ACCOUNT}' / container '{GOLD_CONTAINER}'", False, str(exc))
        return

    # Check each snapshot directory
    for snapshot in SNAPSHOTS:
        directory = f"{SNAPSHOT_ROOT}/{snapshot}"
        try:
            paths = list(fs.get_paths(path=directory))
            json_files = [p.name for p in paths if p.name.endswith(".json")]
            if json_files:
                # Read first file to confirm it is valid JSON lines
                first_file = json_files[0]
                raw = fs.get_file_client(first_file).download_file().readall().decode("utf-8")
                row_count = sum(1 for line in raw.splitlines() if line.strip())
                _record(
                    f"Snapshot '{snapshot}' readable",
                    True,
                    f"{len(json_files)} file(s), {row_count} row(s) in first file — path: {directory}",
                )
            else:
                _record(
                    f"Snapshot '{snapshot}' readable",
                    False,
                    f"Directory exists at {directory} but contains no .json files. "
                    "Run the Databricks Gold notebook to populate it.",
                )
        except Exception as exc:
            _record(
                f"Snapshot '{snapshot}' readable",
                False,
                f"Path: {directory} — {exc}",
            )


# ---------------------------------------------------------------------------
# Layer 2: Gold KPI API
# ---------------------------------------------------------------------------

def test_gold_api() -> None:
    _section("Layer 2 – Gold KPI API")

    if not API_KEY:
        _record("JETOPS_API_KEY configured", False,
                "Set the JETOPS_API_KEY environment variable before running this test.")
        return
    _record("JETOPS_API_KEY configured", True)

    headers = {"x-api-key": API_KEY}

    for path, params, label in GOLD_API_ENDPOINTS:
        url = GOLD_API_BASE + path
        try:
            resp = requests.get(url, headers=headers, params=params, timeout=30)
            if resp.status_code == 200:
                body = resp.json()
                # Spot-check: health must say 'ok', others just need to be non-empty
                if path.endswith("/health"):
                    ok = body.get("status") == "ok"
                    detail = f"status={body.get('status')}"
                elif "results" in body:
                    ok = True
                    detail = f"{len(body['results'])} result(s) returned"
                else:
                    ok = bool(body)
                    detail = f"{len(body)} top-level key(s)"
                _record(f"GET {path} → {label}", ok, detail)
            elif resp.status_code == 401:
                _record(f"GET {path} → {label}", False,
                        "401 Unauthorized — check JETOPS_API_KEY matches the deployed API key.")
            else:
                _record(f"GET {path} → {label}", False,
                        f"HTTP {resp.status_code}: {resp.text[:200]}")
        except requests.exceptions.ConnectionError:
            _record(f"GET {path} → {label}", False,
                    f"Connection refused — is the API running at {GOLD_API_BASE}?")
        except Exception as exc:
            _record(f"GET {path} → {label}", False, str(exc))


# ---------------------------------------------------------------------------
# Layer 3: Azure AI Foundry
# ---------------------------------------------------------------------------

def test_foundry() -> None:
    _section("Layer 3 – Azure AI Foundry Copilot")

    try:
        from azure.ai.projects import AIProjectClient
        from azure.identity import AzureCliCredential
    except ImportError:
        _record("azure-ai-projects + azure-identity installed", None,
                "Run: pip install azure-ai-projects azure-identity  then re-run this test.")
        return

    _record("azure-ai-projects + azure-identity installed", True)

    # Build client
    try:
        credential = AzureCliCredential()
        project_client = AIProjectClient(
            endpoint=FOUNDRY_ENDPOINT,
            credential=credential,
        )
        _record(f"AIProjectClient connected to '{FOUNDRY_ENDPOINT}'", True)
    except Exception as exc:
        _record(f"AIProjectClient connected to '{FOUNDRY_ENDPOINT}'", False,
                f"{exc}  — run 'az login' if you are not authenticated.")
        return

    # List agents — SDK 1.x uses list_agents(), SDK 2.x uses list()
    try:
        agents_client = project_client.agents
        if hasattr(agents_client, "list_agents"):
            agents = list(agents_client.list_agents())          # SDK 1.x (azure-ai-agents)
        else:
            agents = list(agents_client.list())                 # SDK 2.x
        agent_names = [a.name for a in agents]
        found = FOUNDRY_AGENT_NAME in agent_names
        _record(
            f"Agent '{FOUNDRY_AGENT_NAME}' exists in project",
            found,
            f"Agents found: {agent_names}" if not found else "",
        )
        if not found:
            return
        agent_id = next(a.id for a in agents if a.name == FOUNDRY_AGENT_NAME)
    except Exception as exc:
        _record(f"Agent '{FOUNDRY_AGENT_NAME}' exists in project", False, str(exc))
        return

    # Send a test question — use SDK 1.x thread API when available, else OpenAI Responses
    try:
        if hasattr(agents_client, "create_thread_and_process_run"):
            # SDK 1.x (azure-ai-agents style)
            from azure.ai.agents.models import AgentThreadCreationOptions, ThreadMessageOptions, MessageRole
            run = agents_client.create_thread_and_process_run(
                agent_id=agent_id,
                thread=AgentThreadCreationOptions(
                    messages=[ThreadMessageOptions(role=MessageRole.USER, content=FOUNDRY_TEST_QUESTION)]
                ),
            )
            if run.status == "completed":
                messages = list(agents_client.messages.list(thread_id=run.thread_id))
                assistant_msgs = [m for m in messages if m.role == "assistant"]
                answer = assistant_msgs[-1].content[0].text.value if assistant_msgs else ""
            else:
                answer = ""
                _record("Foundry agent answered triage question", False,
                        f"Run ended with status '{run.status}'. Check Foundry portal for details.")
                return
        else:
            # SDK 2.x (OpenAI Responses API via agent-scoped endpoint)
            openai_client = project_client.get_openai_client(agent_name=FOUNDRY_AGENT_NAME)
            response = openai_client.responses.create(
                model=FOUNDRY_MODEL,
                input=FOUNDRY_TEST_QUESTION,
            )
            answer = response.output_text or ""

        if answer:
            _record(
                "Foundry agent answered triage question",
                True,
                f"Answer preview: {answer[:200]}",
            )
        else:
            _record("Foundry agent answered triage question", False,
                    "No answer text returned. Check agent tool wiring in the Foundry portal.")
    except Exception as exc:
        _record("Foundry agent answered triage question", False, str(exc))


# ---------------------------------------------------------------------------
# Entry point
# ---------------------------------------------------------------------------

if __name__ == "__main__":
    print("\nJetOps Smoke Test — ADLS Gen2 · Gold KPI API · Azure AI Foundry")
    print(f"  Storage account : {STORAGE_ACCOUNT}")
    print(f"  Gold API base   : {GOLD_API_BASE}")
    print(f"  Foundry endpoint: {FOUNDRY_ENDPOINT}")

    test_adls()
    test_gold_api()
    test_foundry()
    _summary()
