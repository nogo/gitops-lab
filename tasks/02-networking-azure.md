# Task 02: Networking (Azure)

## Objective

Guide the learner to create a Virtual Network (VNet) and Subnet for their AKS cluster.

## Expected Outcome

```
infrastructure/
├── ...existing files...
├── network.tf      # VNet and Subnet definitions
└── variables.tf    # Add network-related variables
```

## Success Criteria

Run these to validate completion:

```bash
cd infrastructure
terraform plan   # Must show VNet and Subnet resources
terraform apply  # Must create resources

az network vnet show \
  --resource-group <rg-name> \
  --name <vnet-name> \
  --query "{name:name, addressSpace:addressSpace.addressPrefixes}"

az network vnet subnet show \
  --resource-group <rg-name> \
  --vnet-name <vnet-name> \
  --name <subnet-name> \
  --query "{name:name, addressPrefix:addressPrefix}"
```

Additionally, learner should explain why AKS needs its own subnet and justify their CIDR choices.

## Key Decisions to Guide

1. **VNet address space** — Common choice: `10.0.0.0/16`
2. **Subnet sizing** — AKS with Azure CNI needs IPs for nodes AND pods. /24 is tight; /22 is safer
3. **Future growth** — Leave room for additional subnets
4. **Naming** — Consistent with resource group pattern

## Hint Levels

### Level 1 — Direction
"You need two resources: `azurerm_virtual_network` and `azurerm_subnet`. The subnet must reference the VNet."

### Level 2 — Concept
"AKS assigns IPs to nodes, pods, and internal services. With Azure CNI, each pod gets a VNet IP. A /24 gives 256 IPs — might be tight. Consider /22 or /21 for the AKS subnet."

### Level 3 — Structure
"VNet needs: `name`, `location`, `resource_group_name`, `address_space` (list)

Subnet needs: `name`, `resource_group_name`, `virtual_network_name`, `address_prefixes` (list)"

### Level 4 — Pseudocode
```hcl
resource "azurerm_virtual_network" "main" {
  name                = "..."
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  address_space       = ["10.0.0.0/16"]
}

resource "azurerm_subnet" "aks" {
  name                 = "..."
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.0.0/22"]
}
```

### Level 5 — Review
Review their actual code. Common issues:
- Subnet CIDR outside VNet range
- Subnet too small for AKS + pods
- Missing resource group reference

## Common Pitfalls

| Error | Cause | Hint to Give |
|-------|-------|--------------|
| Overlapping CIDR | Subnet outside VNet range | "Is your subnet CIDR within your VNet's address space?" |
| "Subnet in use" | Previous failed deployment | "Check for orphaned resources in the subnet" |
| Subnet too small | Didn't account for pods | "How many IPs do you need for nodes AND pods?" |

## Documentation Links

- [azurerm_virtual_network](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/virtual_network)
- [azurerm_subnet](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/subnet)
- [AKS Networking Concepts](https://learn.microsoft.com/en-us/azure/aks/concepts-network)

## AWS Comparison

If learner asks "how is this different from AWS?":

| AWS | Azure | Notes |
|-----|-------|-------|
| VPC | VNet | Very similar concept |
| Subnet | Subnet | Azure subnets span AZs by default |
| CIDR block | Address space | Same notation |
| Route table | Route table | Azure has implicit system routes |
| No equivalent | Service Endpoints | Direct VNet-to-Azure-service connectivity |

## Networking Mental Model

Share this if learner needs help visualizing:

```
VNet (10.0.0.0/16)
├── aks-subnet (10.0.0.0/22)    ← AKS nodes and pods
├── reserved-1 (10.0.4.0/24)   ← Future: databases, etc.
└── reserved-2 (10.0.5.0/24)   ← Future: other services
```

## On Completion

Update PROGRESS.md:
- Set task 02 status to ✅
- Add notes: CIDR choices and reasoning
