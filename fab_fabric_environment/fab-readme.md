# fab_fabric_environment

This folder contains Terraform files for deploying Microsoft Fabric resources.

- All files are prefixed with `fab-` for clarity.
- Keep this environment separate from Databricks and other compute.

## Usage
1. Update variables in `fab-variables.tf` as needed.
2. Add Fabric resource definitions to `fab-main.tf`.
3. Run `terraform init` and `terraform apply` in this directory.

> Note: Microsoft Fabric is a managed service. Some resources may need to be provisioned via the Fabric portal.


---

## Manual Steps: Microsoft Fabric Portal
Some Microsoft Fabric resources (like workspaces, lakehouses, and notebooks) must be created in the Fabric portal:

1. Go to https://app.fabric.microsoft.com/ and sign in.
2. Create a new workspace (suggested name: `fab-lakehouse-demo` or similar).
3. In the workspace, create a Lakehouse, Data Warehouse, or Notebook as needed.
4. Connect your Azure Storage account (created by Terraform) if required for data landing or integration.
5. Upload sample data or create pipelines as needed.
6. Use the Fabric UI to manage compute, run notebooks, and build analytics/AI workflows.

Refer to the main README for architecture and use case guidance.
