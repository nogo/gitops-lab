# Task 04: Cluster Access (Azure)

## Objective

Guide the learner to configure kubectl to connect to their AKS cluster and verify it's healthy.

## Expected Outcome

- Kubeconfig configured with AKS credentials
- Verified cluster connectivity
- Understanding of AKS authentication flow

## Success Criteria

Run these to validate completion:

```bash
kubectl get nodes
# Must return node(s) in Ready state

kubectl get pods -A
# Must show system pods running in kube-system namespace

kubectl config current-context
# Must show a meaningful context name
```

Additionally, learner should understand how credentials were obtained.

## Key Decisions to Guide

1. **Credential method** — Azure CLI is simplest (`az aks get-credentials`)
2. **Kubeconfig location** — Default `~/.kube/config` is fine for lab
3. **Admin vs User** — `--admin` bypasses AAD, fine for lab; production would use AAD RBAC

## Hint Levels

### Level 1 — Direction
"Azure CLI can fetch AKS credentials directly. Look for a command that gets credentials for an AKS cluster."

### Level 2 — Concept
"The command `az aks get-credentials` fetches cluster credentials and merges them into your kubeconfig. You need to specify the resource group and cluster name."

### Level 3 — Structure
```bash
az aks get-credentials \
  --resource-group <rg-name> \
  --name <cluster-name>
```

Add `--overwrite-existing` if updating an existing entry.

### Level 4 — Pseudocode
```bash
# Get credentials (admin bypasses AAD for simplicity)
az aks get-credentials \
  --resource-group <rg-name> \
  --name <cluster-name> \
  --admin

# Verify connection
kubectl cluster-info
kubectl get nodes
```

### Level 5 — Review
If learner has issues, check:
- Is the cluster provisioning complete? (`az aks show --query provisioningState`)
- Is the correct context active? (`kubectl config current-context`)
- Are credentials fresh? (re-run `az aks get-credentials`)

## Validation Commands

```bash
# Basic connectivity
kubectl cluster-info
kubectl get nodes
kubectl get pods -A

# Context management
kubectl config get-contexts
kubectl config current-context
```

## Expected Output

```
$ kubectl get nodes
NAME                                STATUS   ROLES   AGE   VERSION
aks-system-12345678-vmss000000     Ready    agent   10m   v1.28.x

$ kubectl get pods -n kube-system
NAME                                  READY   STATUS    RESTARTS
coredns-xxxxxxxxx-xxxxx              1/1     Running   0
coredns-autoscaler-xxxxxxxxx-xxxxx   1/1     Running   0
kube-proxy-xxxxx                     1/1     Running   0
metrics-server-xxxxxxxxx-xxxxx       1/1     Running   0
```

## Common Pitfalls

| Error | Cause | Hint to Give |
|-------|-------|--------------|
| "Connection refused" | Cluster not ready | "Is the cluster fully provisioned? Check Azure Portal or `az aks show`" |
| "Unauthorized" | Wrong/expired credentials | "Try re-running the get-credentials command" |
| Wrong cluster | Multiple kubeconfig contexts | "What context is kubectl currently using?" |
| "No resources found" | Wrong namespace | "Are you looking in the right namespace? Try `-A` for all" |

## Documentation Links

- [az aks get-credentials](https://learn.microsoft.com/en-us/cli/azure/aks#az-aks-get-credentials)
- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [AKS AAD Integration](https://learn.microsoft.com/en-us/azure/aks/managed-aad)

## AWS Comparison

If learner asks "how is this different from AWS?":

| AWS (EKS) | Azure (AKS) | Notes |
|-----------|-------------|-------|
| `aws eks update-kubeconfig` | `az aks get-credentials` | Same purpose |
| IAM Authenticator | kubelogin (AAD) | Both inject tokens |
| aws-auth ConfigMap | AKS AAD integration | RBAC mapping |

## Path Selection

**After this task is complete**, prompt the learner to choose their GitOps tool:

"You've completed the foundation infrastructure. Now choose your GitOps tool:

**ArgoCD** — UI-first, visual sync status, single Application CRD
**FluxCD** — CLI-first, built-in image automation, GitRepository + Kustomization CRDs

Which path do you want to take?"

Update PROGRESS.md with their choice before proceeding to Task 05.

## On Completion

Update PROGRESS.md:
- Set task 04 status to ✅
- Record: node count, Kubernetes version
- **Set GitOps Tool choice** (argocd or fluxcd)
