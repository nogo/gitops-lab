# Task 07: GitOps Repo Structure

## Objective

Create a Git repository structure that follows GitOps best practices. This repo will be the source of truth for your applications.

## What You'll Build

```
apps/                          # In your gitops-lab project
├── base/
│   └── nginx/
│       ├── deployment.yaml
│       ├── service.yaml
│       └── kustomization.yaml
├── overlays/
│   └── dev/
│       ├── kustomization.yaml
│       └── namespace.yaml
└── README.md
```

## Success Criteria

- [ ] Git repository initialized (local for now)
- [ ] Base nginx manifests created
- [ ] Kustomize overlay structure in place
- [ ] `kubectl kustomize apps/overlays/dev/` renders valid YAML
- [ ] Structure supports multiple environments (dev/staging/prod pattern)
- [ ] You can explain base vs overlay concept

## Key Decisions You Must Make

1. **Repo structure:** Monorepo (apps + infra) vs separate repos?
2. **Templating:** Kustomize vs Helm vs plain YAML?
3. **Environment strategy:** Folders vs branches?
4. **Namespace strategy:** One per app? Per environment?

## Hints

<details>
<summary>Hint 1 — Why Kustomize</summary>

Kustomize is built into kubectl and ArgoCD. No external tools needed.

Pattern: Base manifests (common) + Overlays (environment-specific patches).

</details>

<details>
<summary>Hint 2 — Base Structure</summary>

`apps/base/nginx/` should contain:
- `deployment.yaml` — The nginx Deployment
- `service.yaml` — ClusterIP Service
- `kustomization.yaml` — Lists the resources

</details>

<details>
<summary>Hint 3 — kustomization.yaml (base)</summary>

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
resources:
  - deployment.yaml
  - service.yaml
```

</details>

<details>
<summary>Hint 4 — Overlay Concept</summary>

`apps/overlays/dev/` references the base and adds environment specifics:
- Namespace
- Replica count patches
- Environment variables
- Resource limits

</details>

<details>
<summary>Hint 5 — Overlay kustomization.yaml</summary>

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: dev
resources:
  - ../../base/nginx
  - namespace.yaml
```

This applies the dev namespace to all resources from base.

</details>

## Validation Commands

```bash
# Test Kustomize renders correctly
kubectl kustomize apps/overlays/dev/

# Dry-run apply (doesn't actually apply)
kubectl apply -k apps/overlays/dev/ --dry-run=client

# Validate YAML syntax
kubectl kustomize apps/overlays/dev/ | kubectl apply --dry-run=client -f -
```

## Sample Manifests

### deployment.yaml (base)
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx
  labels:
    app: nginx
spec:
  replicas: 1
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
        - name: nginx
          image: nginx:1.25
          ports:
            - containerPort: 80
```

### service.yaml (base)
```yaml
apiVersion: v1
kind: Service
metadata:
  name: nginx
spec:
  selector:
    app: nginx
  ports:
    - port: 80
      targetPort: 80
```

*Try to write these yourself first. Use the samples only if stuck.*

## Common Pitfalls

| Issue | Cause | Resolution |
|-------|-------|------------|
| "no kustomization.yaml" | Wrong directory or missing file | Check file exists, correct path |
| Resources not found | Wrong path in kustomization.yaml | Paths are relative to kustomization.yaml |
| "unknown field" | Wrong API version | Check Kustomize version; use `v1beta1` |

## Repo Structure Patterns

### Pattern A: App-of-Apps (Recommended)
```
apps/
├── base/          # Reusable bases
├── overlays/      # Environment configs
└── argocd/        # ArgoCD Application CRDs
```

### Pattern B: Environment Branches
```
main branch     → prod
staging branch  → staging
dev branch      → dev
```
*Harder to see diff across envs. Not recommended.*

### Pattern C: Separate Repos
```
gitops-apps/           # App manifests
gitops-infrastructure/ # Infra definitions
```
*Good for large orgs; overkill for this lab.*

## Documentation

- [Kustomize Docs](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)
- [ArgoCD with Kustomize](https://argo-cd.readthedocs.io/en/stable/user-guide/kustomize/)
- [GitOps Repo Structures](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/)

## Think About

- How would you add a staging environment?
- What if two apps need different nginx versions?
- How do you handle secrets in GitOps? (not in Git!)

## When You're Done

Update `PROGRESS.md`:
- Change task 07 status to ✅
- Unlock task 08
- Note: Repo structure decision, templating choice
