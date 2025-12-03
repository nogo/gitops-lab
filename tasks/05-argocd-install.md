# Task 05: ArgoCD Installation

## Objective

Guide the learner to install ArgoCD using Terraform's Helm provider. This establishes the GitOps control plane.

## Expected Outcome

```
infrastructure/
├── ...existing files...
├── helm.tf         # Helm provider configuration
├── argocd.tf       # ArgoCD Helm release
└── outputs.tf      # Add ArgoCD-related outputs
```

## Success Criteria

Run these to validate completion:

```bash
cd infrastructure
terraform plan   # Must show helm_release for ArgoCD
terraform apply  # Must deploy ArgoCD

kubectl get namespace argocd
# Must exist

kubectl get pods -n argocd
# Must show running pods: application-controller, repo-server, server, redis

terraform apply  # Re-run must show "No changes"
```

Additionally, learner should explain why Helm via Terraform (vs manual helm install or ArgoCD self-managing).

## Key Decisions to Guide

1. **Installation method** — Helm via Terraform keeps platform tools in IaC
2. **Namespace** — `argocd` is standard
3. **HA mode** — Single replica for lab; HA for production
4. **Ingress** — Port-forward for lab; Ingress for production

## Hint Levels

### Level 1 — Direction
"You need the Helm provider for Terraform. It needs connection info from your AKS cluster to deploy charts."

### Level 2 — Concept
"The Helm provider needs kubernetes connection details from the AKS resource. Look at the `kube_config` output from `azurerm_kubernetes_cluster`.

Use `helm_release` resource to deploy the ArgoCD chart from the Argo Helm repository."

### Level 3 — Structure
"Helm provider needs in the `kubernetes` block:
- `host`
- `client_certificate` (base64decode)
- `client_key` (base64decode)
- `cluster_ca_certificate` (base64decode)

helm_release needs:
- `name`, `repository`, `chart`, `version`
- `namespace`, `create_namespace = true`"

### Level 4 — Pseudocode
```hcl
provider "helm" {
  kubernetes {
    host                   = azurerm_kubernetes_cluster.main.kube_config[0].host
    client_certificate     = base64decode(azurerm_kubernetes_cluster.main.kube_config[0].client_certificate)
    client_key             = base64decode(azurerm_kubernetes_cluster.main.kube_config[0].client_key)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.main.kube_config[0].cluster_ca_certificate)
  }
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = "X.Y.Z"  # Pin version
  namespace        = "argocd"
  create_namespace = true
}
```

### Level 5 — Review
If learner has issues, check:
- Are kube_config references correct? (use `[0]` index)
- Is base64decode applied to certificates?
- Is chart version pinned?
- Does helm provider have required_providers block?

## Expected Pods

```
$ kubectl get pods -n argocd
NAME                                               READY   STATUS
argocd-application-controller-xxxxxxxxx-xxxxx     1/1     Running
argocd-redis-xxxxxxxxx-xxxxx                      1/1     Running
argocd-repo-server-xxxxxxxxx-xxxxx                1/1     Running
argocd-server-xxxxxxxxx-xxxxx                     1/1     Running
```

## Common Pitfalls

| Error | Cause | Hint to Give |
|-------|-------|--------------|
| "Kubernetes cluster unreachable" | Provider can't auth | "Check your kube_config references from the AKS resource" |
| Pods in CrashLoopBackOff | Resource constraints | "Is your node size sufficient?" |
| "Release not found" | Namespace issues | "Did you set create_namespace = true?" |
| Timeout on apply | Slow scheduling | "Try increasing the timeout in helm_release" |

## Documentation Links

- [Terraform Helm Provider](https://registry.terraform.io/providers/hashicorp/helm/latest/docs)
- [helm_release Resource](https://registry.terraform.io/providers/hashicorp/helm/latest/docs/resources/release)
- [ArgoCD Helm Chart](https://artifacthub.io/packages/helm/argo/argo-cd)
- [ArgoCD Docs](https://argo-cd.readthedocs.io/)

## FluxCD Comparison

If learner asks how FluxCD differs:

| Aspect | ArgoCD | FluxCD |
|--------|--------|--------|
| Installation | Helm via Terraform | CLI bootstrap |
| Self-management | No (Terraform manages) | Yes (GitOps from start) |
| Config location | Terraform state | Git repo |
| Upgrade process | Terraform apply | Re-run bootstrap |

## Architecture Note

```
Terraform (Infrastructure-as-Code)
  ├── Azure Resources (RG, VNet, AKS)
  └── Helm Releases (ArgoCD) ◄── This task

ArgoCD (GitOps - Application Deployment)
  └── Manages app deployments from Git
```

Separation: Terraform owns cluster + platform tools. ArgoCD owns applications.

## On Completion

Update PROGRESS.md:
- Set task 05 status to ✅
- Add notes: ArgoCD version, HA choice
