# Task 01: Terraform Bootstrap (Azure)

## Objective

Guide the learner to set up Terraform with the Azure provider and create their first resource: a Resource Group.

## Expected Outcome

```
infrastructure/
├── providers.tf    # Azure provider configuration
├── main.tf         # Resource group definition
├── variables.tf    # Input variables
└── outputs.tf      # Output values
```

## Success Criteria

Run these to validate completion:

```bash
cd infrastructure
terraform init      # Must complete without errors
terraform validate  # Must pass
terraform plan      # Must show 1 resource (azurerm_resource_group)
terraform apply     # Must create resource group
az group show --name <resource-group-name>  # Must return resource details
```

Additionally, learner should be able to explain their authentication method choice.

## Key Decisions to Guide

1. **Authentication method** — Azure CLI (`az login`) is simplest for local dev
2. **State storage** — Local for now (remote state is a future concern)
3. **Naming convention** — Suggest a prefix pattern (e.g., `gitops-lab-`)
4. **Region** — Learner's choice, but guide toward low-cost regions

## Hint Levels

### Level 1 — Direction
"Start with the Azure provider documentation. You need to configure the `azurerm` provider before creating any resources."

### Level 2 — Concept
"For local development, Azure CLI authentication is simplest. Run `az login` first, then Terraform uses those credentials automatically. The provider needs a `features {}` block even if empty."

### Level 3 — Structure
"Your `providers.tf` needs:
- A `terraform {}` block with `required_providers`
- A `provider \"azurerm\" {}` block with features

Your `main.tf` needs:
- An `azurerm_resource_group` resource"

### Level 4 — Pseudocode
```hcl
# providers.tf structure
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~> X.0"  # Check registry for latest
    }
  }
}

provider "azurerm" {
  features {}
}
```

### Level 5 — Review
Review their actual code. Common issues:
- Missing `features {}` block (required, even if empty)
- Not pinning provider version
- Wrong resource group arguments

## Common Pitfalls

| Error | Cause | Hint to Give |
|-------|-------|--------------|
| "No subscription found" | Not logged into Azure CLI | "Have you authenticated with Azure? Check `az account show`" |
| "features is required" | Missing features block | "The azurerm provider has a specific requirement for a block that might seem optional..." |
| "Provider not found" | Didn't run init | "What command initializes Terraform and downloads providers?" |
| State file conflicts | Multiple terminals | "Are you running Terraform from multiple places?" |

## Documentation Links

Provide these when appropriate:
- [AzureRM Provider Docs](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs)
- [azurerm_resource_group](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/resource_group)
- [Azure CLI Authentication](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli)

## AWS Comparison

If learner asks "how is this different from AWS?":

| AWS | Azure | Notes |
|-----|-------|-------|
| No equivalent | Resource Group | Azure requires RG; AWS uses tags for grouping |
| `~/.aws/credentials` | `az login` | Azure CLI stores tokens differently |
| Region in provider | Location in resource | Azure calls regions "locations" |

## On Completion

Update PROGRESS.md:
- Set task 01 status to ✅
- Add notes: auth method chosen, region selected
