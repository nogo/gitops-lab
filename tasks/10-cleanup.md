# Task 10: Cleanup

## Objective

Guide the learner to tear down all cloud resources to avoid ongoing costs.

## Expected Outcome

- All cloud resources destroyed
- No orphaned resources
- Understanding of destruction order

## Success Criteria

Run these to validate completion:

```bash
cd infrastructure
terraform destroy
# Must complete successfully

# Azure (if Azure path)
az group show --name <rg-name>
# Must return "Resource group not found"

# AWS (if AWS path)
aws eks describe-cluster --name <cluster-name>
# Must return "ResourceNotFoundException"
```

## Key Concepts to Guide

1. **Destruction order** — Terraform handles dependencies automatically
2. **Idempotency** — Re-running destroy on already-destroyed resources is safe
3. **State management** — State file tracks what was created

## Hint Levels

### Level 1 — Direction
"Terraform has a command to destroy all resources it manages. It will show you what will be destroyed before doing it."

### Level 2 — Concept
"Use `terraform destroy`. It reads the state file to know what exists, then deletes in reverse dependency order (Helm releases → cluster → network → resource group)."

### Level 3 — Structure
```bash
# Preview what will be destroyed
terraform plan -destroy

# Execute destruction
terraform destroy
# Type 'yes' to confirm
```

### Level 4 — Pseudocode
```bash
cd infrastructure

# Optional: preview first
terraform plan -destroy

# Destroy all resources
terraform destroy

# Verify cleanup (Azure)
az group show --name <rg-name>

# Verify cleanup (AWS)
aws eks describe-cluster --name <cluster-name>
```

### Level 5 — Review
If destroy fails:
- Check error message for stuck resource
- Re-run `terraform destroy` (often works on retry)
- For truly stuck resources, use targeted destroy: `terraform destroy -target=<resource>`
- Last resort: manual deletion in cloud console, then `terraform state rm <resource>`

## Destruction Order

Terraform handles this automatically:

```
1. Helm releases (ArgoCD/Flux removed from cluster)
2. Kubernetes cluster deleted
3. Subnet deleted
4. VNet/VPC deleted
5. Resource group deleted (Azure) / resources cleaned up (AWS)
```

## Common Pitfalls

| Error | Cause | Hint to Give |
|-------|-------|--------------|
| "Resource still exists" | Azure/AWS async deletion | "Wait a minute and retry" |
| "Cannot delete, in use" | Dependency issue | "Let Terraform handle the order; just retry" |
| State lock | Previous run crashed | "Check if another terraform process is running" |
| Orphaned disks/volumes | PVCs not cleaned | "Check for leftover storage in cloud console" |

## Cost Awareness

Resources that incur cost until destroyed:
- **Kubernetes cluster** — Control plane + nodes
- **Load Balancers** — If Services used type LoadBalancer
- **Public IPs** — If allocated
- **Storage** — PersistentVolumes, disks

## State File After Destroy

The `terraform.tfstate` file will contain:
- Empty resources list
- Serial number incremented

Options:
- Keep it (allows fresh `terraform apply` later)
- Delete it (truly fresh start)

## Retrospective Questions

After destroy completes, prompt reflection:

1. "What was the most challenging part of this lab?"
2. "What would you do differently in a production setup?"
3. "What topic do you want to explore deeper?"

Possible next steps to suggest:
- Remote state (Azure Storage / S3)
- Private clusters
- Multi-environment (dev/staging/prod)
- Secrets management (External Secrets, Sealed Secrets)
- Monitoring stack via GitOps

## Documentation Links

- [terraform destroy](https://developer.hashicorp.com/terraform/cli/commands/destroy)
- [Azure: Delete Resource Group](https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/delete-resource-group)
- [AWS: Delete EKS Cluster](https://docs.aws.amazon.com/eks/latest/userguide/delete-cluster.html)

## On Completion

Update PROGRESS.md:
- Set task 10 status to ✅
- Add final notes: learnings, challenges, next steps

Congratulate the learner on completing the lab.
