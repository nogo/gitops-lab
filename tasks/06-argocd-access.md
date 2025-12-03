# Task 06: ArgoCD Access

## Objective

Access the ArgoCD UI and configure the CLI. Retrieve initial admin credentials and verify the installation works.

## What You'll Achieve

- ArgoCD web UI accessible
- ArgoCD CLI (`argocd`) installed and authenticated
- Initial admin password retrieved and understood
- Ready to create Applications

## Success Criteria

- [ ] Can access ArgoCD UI in browser
- [ ] Know the initial admin password
- [ ] ArgoCD CLI installed locally
- [ ] `argocd login` succeeds
- [ ] `argocd cluster list` shows in-cluster
- [ ] You understand port-forward vs Ingress trade-offs

## Key Decisions You Must Make

1. **Access method:** Port-forward (simple) or Ingress (production-like)?
2. **Password:** Use initial password or change it?
3. **CLI installation:** brew/apt/binary download?

## Hints

<details>
<summary>Hint 1 — Port Forward</summary>

Quickest way to access ArgoCD:
```bash
kubectl port-forward svc/argocd-server -n argocd 8080:443
```
Then open https://localhost:8080 (accept self-signed cert warning)

</details>

<details>
<summary>Hint 2 — Initial Password</summary>

ArgoCD stores the initial admin password in a Secret. The password is the name of the argocd-server pod... but there's also a dedicated secret.

Look for a secret named `argocd-initial-admin-secret` in the argocd namespace.

</details>

<details>
<summary>Hint 3 — Get Password Command</summary>

```bash
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d
```

Username is `admin`.

</details>

<details>
<summary>Hint 4 — CLI Installation</summary>

macOS: `brew install argocd`
Linux: Download from GitHub releases

Or use the version matching your server:
```bash
VERSION=$(kubectl -n argocd get deploy argocd-server \
  -o jsonpath='{.spec.template.spec.containers[0].image}' | cut -d: -f2)
```

</details>

<details>
<summary>Hint 5 — CLI Login</summary>

With port-forward running:
```bash
argocd login localhost:8080 --username admin --password <password> --insecure
```

The `--insecure` skips TLS verification (self-signed cert).

</details>

## Validation Commands

```bash
# Start port-forward (keep running in separate terminal)
kubectl port-forward svc/argocd-server -n argocd 8080:443

# Get initial password
kubectl -n argocd get secret argocd-initial-admin-secret \
  -o jsonpath="{.data.password}" | base64 -d && echo

# Install CLI (macOS)
brew install argocd

# Login
argocd login localhost:8080 --username admin --password <pw> --insecure

# Verify
argocd cluster list
argocd app list  # Should be empty
argocd version
```

## Expected Output

```
$ argocd cluster list
SERVER                          NAME        VERSION  STATUS   MESSAGE
https://kubernetes.default.svc  in-cluster           Unknown  Cluster has no application...

$ argocd app list
NAME  CLUSTER  NAMESPACE  PROJECT  STATUS  HEALTH  SYNCPOLICY  CONDITIONS
(empty)
```

## Common Pitfalls

| Issue | Cause | Resolution |
|-------|-------|------------|
| "Connection refused" on 8080 | Port-forward died | Re-run port-forward command |
| "x509 certificate" error | Self-signed cert | Use `--insecure` or accept in browser |
| "Secret not found" | Wrong namespace | Ensure `-n argocd` |
| Empty password | Secret deleted or not created | Check ArgoCD Helm values; may need reset |
| CLI version mismatch | Server/CLI versions differ | Install matching CLI version |

## Documentation

- [ArgoCD Getting Started](https://argo-cd.readthedocs.io/en/stable/getting_started/)
- [ArgoCD CLI Installation](https://argo-cd.readthedocs.io/en/stable/cli_installation/)
- [ArgoCD Ingress Configuration](https://argo-cd.readthedocs.io/en/stable/operator-manual/ingress/)

## Security Note

The initial admin password method is for bootstrapping. In production:
- Disable admin user after creating proper accounts
- Use SSO/OIDC integration (Azure AD, Okta, etc.)
- Store secrets in proper secret management (Azure Key Vault)

For this lab, initial password is fine.

## ArgoCD Architecture Overview

```
┌─────────────────────────────────────────────────┐
│ ArgoCD Server (argocd-server)                   │
│  ├── API Server (gRPC + REST)                   │
│  ├── Web UI (React)                             │
│  └── CLI endpoint                               │
├─────────────────────────────────────────────────┤
│ Repo Server (argocd-repo-server)                │
│  └── Clones Git repos, renders manifests        │
├─────────────────────────────────────────────────┤
│ Application Controller                          │
│  └── Monitors apps, syncs state                 │
├─────────────────────────────────────────────────┤
│ Redis                                           │
│  └── Caching layer                              │
└─────────────────────────────────────────────────┘
```

## Think About

- Why does ArgoCD need its own access control separate from Kubernetes RBAC?
- How would you expose ArgoCD externally in production?
- What's the "in-cluster" cluster that shows up by default?

## When You're Done

Update `PROGRESS.md`:
- Change task 06 status to ✅
- Unlock task 07
- Note: Access method chosen, CLI version
