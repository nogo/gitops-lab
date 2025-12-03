# Task 07: GitOps Repo Structure (FluxCD Path)

## Objective

Create the application manifests that FluxCD will deploy. The Kustomize structure is the same as ArgoCD — both tools understand Kustomize natively.

## What You'll Build

```
apps/                          # Application manifests
├── base/
│   └── nginx/
│       ├── deployment.yaml
│       ├── service.yaml
│       └── kustomization.yaml
├── overlays/
│   └── dev/
│       ├── kustomization.yaml
│       └── namespace.yaml
```

Plus FluxCD-specific resources in:
```
clusters/
└── dev/
    └── flux-system/          # Created by bootstrap
    └── apps.yaml             # You'll create this (GitRepository + Kustomization for apps)
```

## ArgoCD vs FluxCD: Key Difference

- **ArgoCD**: One `Application` CRD points to a path and handles everything
- **FluxCD**: Separate `GitRepository` (source) + `Kustomization` (what to deploy) CRDs

More granular, more explicit.

## Success Criteria

- [ ] Base nginx manifests created (same as ArgoCD path)
- [ ] Kustomize overlay structure in place
- [ ] `kubectl kustomize apps/overlays/dev/` renders valid YAML
- [ ] Structure supports multiple environments
- [ ] You understand how Flux will reference this structure

## Key Decisions You Must Make

1. **Repo structure:** Apps in same repo as Flux config? (yes for this lab)
2. **Templating:** Kustomize vs Helm? (Kustomize for simplicity)
3. **Environment strategy:** Folders (recommended) vs branches

## Hints

<details>
<summary>Hint 1 — Why Kustomize with Flux</summary>

Flux has a native Kustomize controller. It runs `kustomize build` on the path you specify and applies the result.

Pattern: Base manifests + Overlays — same as ArgoCD.

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
<summary>Hint 4 — Overlay kustomization.yaml</summary>

```yaml
apiVersion: kustomize.config.k8s.io/v1beta1
kind: Kustomization
namespace: development
resources:
  - ../../base/nginx
  - namespace.yaml
```

</details>

<details>
<summary>Hint 5 — Flux Path Convention</summary>

Common Flux repo structure:
```
clusters/           # Per-cluster Flux config
├── dev/
│   ├── flux-system/    # Flux self-management (from bootstrap)
│   └── apps.yaml       # Points to apps/overlays/dev
├── staging/
└── prod/

apps/               # Application manifests (shared)
├── base/
└── overlays/
    ├── dev/
    ├── staging/
    └── prod/
```

</details>

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

### namespace.yaml (overlay)
```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: development
```

*Try to write these yourself first.*

## Validation Commands

```bash
# Test Kustomize renders correctly
kubectl kustomize apps/overlays/dev/

# Dry-run apply
kubectl apply -k apps/overlays/dev/ --dry-run=client

# Validate YAML syntax
kubectl kustomize apps/overlays/dev/ | kubectl apply --dry-run=client -f -
```

## Common Pitfalls

| Issue | Cause | Resolution |
|-------|-------|------------|
| "no kustomization.yaml" | Wrong directory or missing file | Check file exists, correct path |
| Resources not found | Wrong path in kustomization.yaml | Paths are relative to kustomization.yaml |
| "unknown field" | Wrong API version | Use `kustomize.config.k8s.io/v1beta1` |

## Documentation

- [Kustomize Docs](https://kubectl.docs.kubernetes.io/guides/introduction/kustomize/)
- [Flux Kustomization](https://fluxcd.io/flux/components/kustomize/)
- [Flux Repository Structure](https://fluxcd.io/flux/guides/repository-structure/)

## Think About

- How would you add a staging environment?
- What if nginx needs different resource limits per environment?
- How would Flux know to deploy from `apps/overlays/dev/`? (next task!)

## When You're Done

Update `PROGRESS.md`:
- Change task 07-fluxcd-repo status to ✅
- Unlock task 08-fluxcd-first-app
- Note: Structure created, Kustomize validated
