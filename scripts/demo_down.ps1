# JetOps Demo — tear down billed infrastructure between demo sessions.
#
# Surgically destroys only the resources that bill 24/7 regardless of use,
# via `terraform destroy -target=...`, and leaves everything data-bearing
# or free-to-run alone:
#   KEPT (never destroyed): both resource groups, the SQL server + database,
#   both storage accounts (+ their raw/bronze/silver/gold containers),
#   the Databricks workspace, and Azure AI Search (RAG index) — all data
#   or config you don't want to rebuild every demo.
#   DESTROYED: AKS, the VM, Container Registry, VNets/subnets/NSGs/private
#   endpoints/DNS, identities and role assignments in the root state; the
#   Event Hubs namespace and Stream Analytics job in lakehouse/ — these are
#   the only lakehouse resources that bill by the hour whether or not
#   they're in use.
#
# NOT included: databricks_cluster/. That module needs its own
# DATABRICKS_HOST/DATABRICKS_TOKEN secrets, and the cluster already has
# autotermination_minutes = 30, so it isn't a flat 24/7 charge worth
# cycling every demo.
#
# Requires: az login (to the sub-jetops-prod subscription), and
#   $env:TF_VAR_sql_admin_password
#   $env:TF_VAR_rycrawl_admin_password
# set before running (values don't matter for a destroy — Terraform just
# needs something to satisfy the variable, it never reads them back).
#
# NOTE: this -target list is hand-maintained against the .tf files as of
# 2026-07. If resources are added/renamed in root or lakehouse/, update the
# lists below to match, or a plain `terraform plan -destroy` will drift out
# of sync with what this script actually tears down.

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot

$lakehouseTargets = @(
    "azurerm_eventhub_namespace.herbalife_ns",
    "azurerm_eventhub.herbalife_hub",
    "azurerm_eventhub_authorization_rule.herbalife_send",
    "azurerm_stream_analytics_job.herbalife_stream_job",
    "azurerm_stream_analytics_stream_input_eventhub.herbalife_eventhub_input",
    "azurerm_stream_analytics_output_blob.herbalife_raw_output",
    # Pulled in by Terraform automatically: its app_settings reference the
    # Event Hub connection string/name directly, so it must be destroyed
    # alongside the namespace. Harmless — Y1 Consumption plan, no idle cost.
    "azurerm_linux_function_app.eventhub_func"
)

$rootTargets = @(
    "azurerm_container_registry.acr",
    "azurerm_federated_identity_credential.aviator_federated_credential",
    "azurerm_kubernetes_cluster.aviator_core",
    "azurerm_network_interface.rycrawl_test_nic",
    "azurerm_network_security_group.rycrawl_test_nsg",
    "azurerm_network_security_group.sql_endpoint_nsg",
    "azurerm_network_security_rule.allow_sql_from_aks",
    "azurerm_network_security_rule.rycrawl_test_rdp",
    "azurerm_private_dns_zone.sql_dns",
    "azurerm_private_dns_zone_virtual_network_link.sql_dns_link",
    "azurerm_private_endpoint.sql_endpoint",
    "azurerm_private_endpoint.sql_private_endpoint",
    "azurerm_public_ip.rycrawl_test_public_ip",
    "azurerm_role_assignment.acr_pull",
    "azurerm_role_assignment.aks_to_acr",
    "azurerm_role_assignment.sql_reader",
    "azurerm_subnet.endpoint_subnet",
    "azurerm_subnet.rycrawl_test_subnet",
    "azurerm_subnet.sql_subnet",
    "azurerm_subnet_network_security_group_association.endpoint_subnet_assoc",
    "azurerm_subnet_network_security_group_association.rycrawl_test_subnet_assoc",
    "azurerm_user_assigned_identity.aviator_app_identity",
    "azurerm_user_assigned_identity.aviator_identity",
    "azurerm_virtual_network.hub",
    "azurerm_virtual_network.spoke",
    "azurerm_virtual_network_peering.hub_to_spoke",
    "azurerm_windows_virtual_machine.rycrawl_test"
)

if (-not $env:TF_VAR_sql_admin_password -or -not $env:TF_VAR_rycrawl_admin_password) {
    Write-Host "Set these before running (Terraform needs a value even though a destroy never uses it):" -ForegroundColor Red
    Write-Host '  $env:TF_VAR_sql_admin_password = "placeholder"' -ForegroundColor Yellow
    Write-Host '  $env:TF_VAR_rycrawl_admin_password = "placeholder"' -ForegroundColor Yellow
    exit 1
}

if (-not $Force) {
    Write-Host "This will destroy AKS, the VM, ACR, and networking in rg-aviator-core-prod," -ForegroundColor Yellow
    Write-Host "and the Event Hubs namespace + Stream Analytics job in rg-herbalife-dev-core." -ForegroundColor Yellow
    Write-Host "Storage accounts, SQL database, Databricks workspace, and AI Search are kept." -ForegroundColor Yellow
    $answer = Read-Host "Type 'yes' to continue"
    if ($answer -ne "yes") {
        Write-Host "Aborted." -ForegroundColor Cyan
        exit 0
    }
}

Write-Host "--- Destroying lakehouse/ Event Hubs + Stream Analytics ---" -ForegroundColor Cyan
Push-Location (Join-Path $repoRoot "lakehouse")
terraform init -input=false
if ($LASTEXITCODE -ne 0) { Pop-Location; exit $LASTEXITCODE }
$lakehouseArgs = @("destroy", "-auto-approve") + ($lakehouseTargets | ForEach-Object { "-target=$_" })
terraform @lakehouseArgs
$lakehouseExit = $LASTEXITCODE
Pop-Location
if ($lakehouseExit -ne 0) {
    Write-Host "lakehouse destroy failed (exit $lakehouseExit). Stopping before touching root." -ForegroundColor Red
    exit $lakehouseExit
}

Write-Host "--- Destroying root AKS, VM, ACR, and networking ---" -ForegroundColor Cyan
Push-Location $repoRoot
terraform init -input=false
if ($LASTEXITCODE -ne 0) { Pop-Location; exit $LASTEXITCODE }
$rootArgs = @("destroy", "-auto-approve") + ($rootTargets | ForEach-Object { "-target=$_" })
terraform @rootArgs
$rootExit = $LASTEXITCODE
Pop-Location
if ($rootExit -ne 0) {
    Write-Host "root destroy failed (exit $rootExit)." -ForegroundColor Red
    exit $rootExit
}

Write-Host "--- Demo compute/networking torn down. Storage, SQL, Databricks workspace, and AI Search are still running. ---" -ForegroundColor Cyan
