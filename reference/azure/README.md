# Azure Reference Implementation

These files are **reference implementations** for the GitOps Lab Azure path.

## Purpose

Use these to:
- Compare against your work when stuck
- Understand the expected structure
- Verify your approach is reasonable

## Do NOT

- Copy-paste without understanding
- Use these as your starting point
- Skip the learning process

## Structure

```
azure/
├── 01-bootstrap/     # Task 01: Terraform + Resource Group
│   ├── providers.tf
│   ├── variables.tf
│   ├── main.tf
│   └── outputs.tf
├── 02-networking/    # Task 02: VNet + Subnet
│   └── network.tf
├── 03-cluster/       # Task 03: AKS Cluster
│   ├── aks.tf
│   └── outputs.tf
└── 04-access/        # Task 04: Helm Provider (for ArgoCD path)
    └── helm.tf
```

## Notes

- These files are meant to be combined into a single `infrastructure/` directory
- They're split here for clarity per task
- Version numbers may need updating (check Terraform Registry)
