# Task 03: Kubernetes Cluster (Azure)

## Objective

Guide the learner to deploy an AKS cluster using Terraform. This is the core infrastructure for GitOps.

## Expected Outcome

```
infrastructure/
├── ...existing files...
├── aks.tf          # AKS cluster definition
└── outputs.tf      # Add cluster outputs (name, resource group, etc.)
```

## Success Criteria

Run these to validate completion:

```bash
cd infrastructure
terraform plan   # Must show AKS cluster resource
terraform apply  # Takes 5-15 minutes

az aks show \
  --resource-group <rg-name> \
  --name <cluster-name> \
  --query "{name:name, state:provisioningState, kubernetesVersion:kubernetesVersion}"
# provisioningState must be "Succeeded"

az aks nodepool list \
  --resource-group <rg-name> \
  --cluster-name <cluster-name> \
  --query "[].{name:name, count:count, vmSize:vmSize}"
# Must show at least 1 node
```

Additionally, learner should explain difference between kubenet and Azure CNI.

## Key Decisions to Guide

1. **Network plugin** — Azure CNI for custom VNet (assigns VNet IPs to pods)
2. **Node size** — `Standard_B2s` (cheap) or `Standard_DS2_v2` (reliable) for lab
3. **Node count** — 1 is fine for lab
4. **Identity** — SystemAssigned managed identity (modern approach)
5. **Kubernetes version** — Latest stable unless specific reason

## Hint Levels

### Level 1 — Direction
"The resource is `azurerm_kubernetes_cluster`. Focus on the required blocks first: `default_node_pool`, `identity`, and network configuration."

### Level 2 — Concept
"Required arguments: `name`, `location`, `resource_group_name`, `dns_prefix`, `default_node_pool {}`, `identity {}`

The `default_node_pool` needs: `name`, `node_count`, `vm_size`, `vnet_subnet_id`"

### Level 3 — Structure
"For custom VNet, you want Azure CNI (`network_plugin = \"azure\"`). This goes in a `network_profile {}` block.

With Azure CNI, you also need `service_cidr` and `dns_service_ip` — these must NOT overlap with your VNet."

### Level 4 — Pseudocode
```hcl
resource "azurerm_kubernetes_cluster" "main" {
  name                = "..."
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  dns_prefix          = "..."

  default_node_pool {
    name           = "system"
    node_count     = 1
    vm_size        = "Standard_B2s"
    vnet_subnet_id = azurerm_subnet.aks.id
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
    service_cidr   = "10.1.0.0/16"  # NOT in VNet
    dns_service_ip = "10.1.0.10"
  }
}
```

### Level 5 — Review
Review their actual code. Common issues:
- service_cidr overlapping with VNet CIDR
- dns_service_ip not within service_cidr
- Missing vnet_subnet_id in node pool
- Using service principal instead of managed identity

## Common Pitfalls

| Error | Cause | Hint to Give |
|-------|-------|--------------|
| "Quota exceeded" | Region VM limit | "Check your subscription quota for that VM size in that region" |
| "Subnet not found" | Wrong subnet reference | "Are you referencing the subnet correctly? It needs the `.id` attribute" |
| "CIDR overlap" | service_cidr overlaps VNet | "Your Kubernetes service CIDR must be outside your VNet range" |
| "dns_service_ip not in range" | Must be within service_cidr | "Where should the DNS service IP be relative to the service CIDR?" |
| Takes forever | Normal | "AKS creation typically takes 5-15 minutes. This is normal." |

## Documentation Links

- [azurerm_kubernetes_cluster](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/kubernetes_cluster)
- [AKS Networking Options](https://learn.microsoft.com/en-us/azure/aks/concepts-network)
- [AKS VM Sizes](https://learn.microsoft.com/en-us/azure/aks/quotas-skus-regions)

## AWS Comparison

If learner asks "how is this different from AWS?":

| AWS (EKS) | Azure (AKS) | Notes |
|-----------|-------------|-------|
| EKS Cluster | AKS Cluster | Similar concept |
| Managed Node Group | Node Pool | Azure calls them "agent pools" |
| IAM Role | Managed Identity | Both use cloud-native identity |
| VPC CNI | Azure CNI | Both assign VPC/VNet IPs to pods |
| eksctl | az aks create | CLI tools; we're using Terraform |

## Network Config Mental Model

Share this diagram if learner is confused about CIDRs:

```
Your VNet: 10.0.0.0/16
  └── AKS Subnet: 10.0.0.0/22 (nodes + pod IPs)

Service CIDR: 10.1.0.0/16  (internal K8s services - NOT in VNet)
  └── DNS Service IP: 10.1.0.10

Docker Bridge: 172.17.0.1/16 (default, rarely changed)
```

## On Completion

Update PROGRESS.md:
- Set task 03 status to ✅
- Add notes: VM size, node count, network plugin choice
