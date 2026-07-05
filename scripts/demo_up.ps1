# JetOps Demo — rebuild the compute/networking torn down by demo_down.ps1,
# before a demo session. The SQL database, both storage accounts, the
# Databricks workspace, and AI Search were never destroyed, so this apply
# only recreates AKS, the VM, ACR, networking/private endpoints, and the
# Event Hubs namespace + Stream Analytics job.
#
# Mirrors what .github/workflows/deploy.yml and herbalife-lakehouse.yml apply
# in CI: root Terraform first, then lakehouse/. No -var-file is passed for
# lakehouse, same as CI — it relies on the defaults in lakehouse/variables.tf.
#
# IMPORTANT — unlike demo_down.ps1, these values are NOT throwaway here:
#   TF_VAR_sql_admin_password  MUST be the real, current SQL admin password.
#     The SQL server was never destroyed, so if this doesn't match what's
#     already set, Terraform will detect a diff on apply and silently RESET
#     the live SQL server's admin password to whatever you pass.
#   TF_VAR_rycrawl_admin_password can be any value you want — the VM is
#     destroyed and recreated fresh every cycle, so this just becomes its
#     new admin password.
#
# Requires: az login (to the sub-jetops-prod subscription), and both
# env vars above set before running. Expect several minutes for AKS +
# private endpoints + DNS to come back up.
#
# Pass -Force to skip the interactive confirmation below (e.g. when running
# non-interactively) — only do this once you're already certain
# TF_VAR_sql_admin_password is the real current password.

param(
    [switch]$Force
)

$ErrorActionPreference = "Stop"
$repoRoot = Split-Path -Parent $PSScriptRoot

if (-not $env:TF_VAR_sql_admin_password -or -not $env:TF_VAR_rycrawl_admin_password) {
    Write-Host "Set these before running:" -ForegroundColor Red
    Write-Host '  $env:TF_VAR_sql_admin_password = "<the real, current SQL admin password>"' -ForegroundColor Yellow
    Write-Host '  $env:TF_VAR_rycrawl_admin_password = "<any password for the new VM>"' -ForegroundColor Yellow
    exit 1
}

if (-not $Force) {
    Write-Host "Confirm TF_VAR_sql_admin_password is the REAL current SQL admin password, not a placeholder." -ForegroundColor Yellow
    Write-Host "An apply with the wrong value will reset the live SQL server's password." -ForegroundColor Yellow
    $sqlConfirm = Read-Host "Type 'yes' to confirm and continue"
    if ($sqlConfirm -ne "yes") {
        Write-Host "Aborted." -ForegroundColor Cyan
        exit 0
    }
}

Write-Host "--- Applying root (AKS, VM, SQL, ACR, networking) ---" -ForegroundColor Cyan
Push-Location $repoRoot
terraform init -input=false
if ($LASTEXITCODE -ne 0) { Pop-Location; exit $LASTEXITCODE }
terraform apply -auto-approve
$rootExit = $LASTEXITCODE
Pop-Location
if ($rootExit -ne 0) {
    Write-Host "root apply failed (exit $rootExit). Stopping before lakehouse." -ForegroundColor Red
    exit $rootExit
}

Write-Host "--- Applying lakehouse/ (Event Hubs, Databricks workspace, Storage, Search, App Insights) ---" -ForegroundColor Cyan
Push-Location (Join-Path $repoRoot "lakehouse")
terraform init -input=false
if ($LASTEXITCODE -ne 0) { Pop-Location; exit $LASTEXITCODE }
terraform apply -auto-approve
$lakehouseExit = $LASTEXITCODE
Pop-Location
if ($lakehouseExit -ne 0) {
    Write-Host "lakehouse apply failed (exit $lakehouseExit)." -ForegroundColor Red
    exit $lakehouseExit
}

Write-Host "--- Rebuild complete. Refreshing AKS credentials ---" -ForegroundColor Cyan
az aks get-credentials --resource-group rg-aviator-core-prod --name aks-aviator-core --overwrite-existing

Write-Host "--- Outputs ---" -ForegroundColor Cyan
Push-Location $repoRoot
terraform output
Pop-Location
Push-Location (Join-Path $repoRoot "lakehouse")
terraform output
Pop-Location

Write-Host "--- Demo infrastructure is up. Run scripts/demo_start.ps1 next. ---" -ForegroundColor Cyan
