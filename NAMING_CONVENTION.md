# Jetops-Lakehouse Naming Convention

**Subscription:** sub-jetops-prod  
**Tenant:** 5ef08eb8-8ed2-49b3-8eb2-46fba1215518  
**Region:** eastus2 (primary)  
**Environment:** prod  

---

## Naming Pattern Format
`{resource-type}-{project}-{environment}-{purpose}`  
Example: `rg-jetops-prod-state`

---

## Core Infrastructure Resources

### 1. Resource Groups
| Resource | Name | Purpose |
|----------|------|---------|
| RG - Terraform State | `rg-jetops-terraform-state` | Backend state management |
| RG - Core Platform | `rg-jetops-prod-core` | AKS, networking, core services |
| RG - Data | `rg-jetops-prod-data` | SQL Database, storage |
| RG - Monitoring | `rg-jetops-prod-monitoring` | Log Analytics, App Insights |

---

### 2. Storage Accounts (Terraform Backend)
| Resource | Name | Purpose |
|----------|------|---------|
| Storage Account | `stjetopsstate001` | Terraform state (globally unique) |
| Blob Container | `tfstate` | State files container |

**Note:** Storage account names are globally unique, no hyphens allowed

---

### 3. Networking Resources
| Resource | Name | Pattern |
|----------|------|---------|
| Hub VNet | `vnet-jetops-prod-hub` | Hub network |
| Spoke VNet | `vnet-jetops-prod-spoke` | Workload network |
| Subnets | `subnet-{purpose}-jetops-prod` | Gateway, AKS, DB, etc. |
| NSG | `nsg-{purpose}-jetops-prod` | Network security groups |

---

### 4. Compute Resources (AKS)
| Resource | Name | Pattern |
|----------|------|---------|
| AKS Cluster | `aks-jetops-prod` | Kubernetes cluster |
| ACR Registry | `acrjetopsprod` | Container registry (no hyphens) |
| Node Pool | `nodepool1` | Default node pool |

---

### 5. Database Resources
| Resource | Name | Pattern |
|----------|------|---------|
| SQL Server | `sql-jetops-prod` | SQL Server instance |
| SQL Database | `db-jetops-prod` | Database name |
| Key Vault | `kv-jetops-prod` | Secrets management |

---

### 6. Managed Identity
| Resource | Name | Pattern |
|----------|------|---------|
| User Assigned MI | `id-jetops-prod-app` | Application workload identity |

---

### 7. Monitoring & Logging
| Resource | Name | Pattern |
|----------|------|---------|
| Log Analytics | `law-jetops-prod` | Logs workspace |
| App Insights | `ai-jetops-prod` | Application monitoring |

---

## Naming Rules Summary

✅ **DO:**
- Use lowercase for all names
- Use hyphens to separate words (except storage accounts)
- Keep names concise but descriptive
- Include environment indicator (prod)
- Use consistent prefixes (rg-, vnet-, aks-, etc.)

❌ **DON'T:**
- Use uppercase letters
- Use underscores (use hyphens instead)
- Use special characters except hyphens
- Make names too long
- Mix naming patterns

---

## Variables for Terraform

```hcl
locals {
  project     = "jetops"
  environment = "prod"
  region      = "eastus2"
  
  common_tags = {
    Project     = local.project
    Environment = local.environment
    ManagedBy   = "Terraform"
    CreatedDate = timestamp()
  }
}
```

---

## Deployment Order

1. **Resource Group:** `rg-jetops-terraform-state`
2. **Storage Account:** `stjetopsstate001`
3. **Update Terraform Backend configuration**
4. **Create remaining RGs and resources**

---

**Status:** Ready for implementation ✓
