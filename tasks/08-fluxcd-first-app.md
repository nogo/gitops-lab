# Task 08: First Application (FluxCD Path)

## Objective

Create FluxCD resources to deploy your nginx app from Git. This connects your application manifests to the Flux reconciliation loop.

## What You'll Build

```
clusters/
└── dev/
    ├── flux-system/          # From bootstrap
    └── apps.yaml             # NEW: Kustomization pointing to apps/overlays/dev
```

## ArgoCD vs FluxCD: Key Difference

- **ArgoCD**: Single `Application` CRD with source + destination + sync policy
- **FluxCD**: Separate concerns:
  - `GitRepository` — already exists (flux-system watches your repo)
  - `Kustomization` — tells Flux which path to deploy

Since bootstrap already created a GitRepository for your repo, you only need a Kustomization.

## Success Criteria

- [ ] Kustomization resource created pointing to `apps/overlays/dev`
- [ ] Resource committed and pushed to Git
- [ ] Flux reconciles and deploys nginx
- [ ] nginx pods running in `development` namespace
- [ ] `flux get kustomizations` shows "Ready: True"
- [ ] You can explain GitRepository vs Kustomization

## Key Decisions You Must Make

1. **Prune:** Delete resources removed from Git?
2. **Health checks:** Wait for deployments to be healthy?
3. **Interval:** How often to check for changes?
4. **Depends on:** Order relative to other Kustomizations?

## Hints

<details>
<summary>Hint 1 — Flux Kustomization CRD</summary>

Not to be confused with Kustomize's `kustomization.yaml`!

Flux's `Kustomization` CRD tells the kustomize-controller:
- Which GitRepository to use as source
- Which path within that repo to build
- Where to apply the result

</details>

<details>
<summary>Hint 2 — Basic Kustomization</summary>

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: apps
  namespace: flux-system
spec:
  interval: 5m
  path: ./apps/overlays/dev
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
```

</details>

<details>
<summary>Hint 3 — With Health Checks</summary>

```yaml
apiVersion: kustomize.toolkit.fluxcd.io/v1
kind: Kustomization
metadata:
  name: apps
  namespace: flux-system
spec:
  interval: 5m
  path: ./apps/overlays/dev
  prune: true
  sourceRef:
    kind: GitRepository
    name: flux-system
  healthChecks:
    - apiVersion: apps/v1
      kind: Deployment
      name: nginx
      namespace: development
  timeout: 2m
```

</details>

<details>
<summary>Hint 4 — Apply via Git (GitOps way)</summary>

1. Create `clusters/dev/apps.yaml` with the Kustomization
2. Commit and push
3. Flux detects the change and creates the Kustomization
4. Kustomization reconciles and deploys nginx

Or apply directly first to test:
```bash
kubectl apply -f clusters/dev/apps.yaml
```

</details>

<details>
<summary>Hint 5 — Checking Status</summary>

```bash
# Watch Kustomizations
flux get kustomizations --watch

# Check specific Kustomization
flux get kustomization apps

# Detailed status
kubectl describe kustomization apps -n flux-system

# See what was applied
flux get kustomization apps -o yaml
```

</details>

## Validation Commands

```bash
# After committing and pushing (or kubectl apply):

# Check Kustomization status
flux get kustomizations

# Should show both flux-system and apps
# apps should be Ready: True

# Verify nginx deployed
kubectl get pods -n development
kubectl get svc -n development

# Check deployment status
kubectl rollout status deployment/nginx -n development
```

## Expected Output

```
$ flux get kustomizations
NAME        REVISION          SUSPENDED  READY  MESSAGE
flux-system main@sha1:abc123  False      True   Applied revision: main@sha1:abc123
apps        main@sha1:abc123  False      True   Applied revision: main@sha1:abc123

$ kubectl get pods -n development
NAME                     READY   STATUS    RESTARTS   AGE
nginx-xxxxxxxxx-xxxxx    1/1     Running   0          1m
```

## File Structure After This Task

```
gitops-lab/
├── apps/
│   ├── base/nginx/
│   └── overlays/dev/
├── clusters/
│   └── dev/
│       ├── flux-system/      # Flux self-management
│       └── apps.yaml         # NEW: Points to apps/overlays/dev
└── infrastructure/           # Terraform (separate concern)
```

## Common Pitfalls

| Issue | Cause | Resolution |
|-------|-------|------------|
| "source not found" | Wrong sourceRef name | Use `flux-system` (from bootstrap) |
| "path not found" | Wrong path in spec | Paths are relative to repo root |
| READY: False | Kustomize build failed | Check `kubectl describe kustomization apps -n flux-system` |
| Namespace not created | Kustomize not applying namespace.yaml | Check your overlay includes it |
| Prune deleting things | `prune: true` removing unexpected resources | Verify path is correct |

## GitOps Flow

```
┌─────────────────────────────────────────────────────────┐
│ Git Repository                                          │
│  ├── clusters/dev/apps.yaml (Kustomization CR)         │
│  └── apps/overlays/dev/ (nginx manifests)              │
└────────────────────────┬────────────────────────────────┘
                         │
          ┌──────────────┴──────────────┐
          ▼                              ▼
┌──────────────────┐          ┌──────────────────┐
│ source-controller│          │kustomize-controller│
│ (fetches Git)    │─────────▶│ (builds & applies) │
└──────────────────┘          └────────┬─────────┘
                                       │
                                       ▼
                              ┌──────────────────┐
                              │   Kubernetes     │
                              │  (nginx pods)    │
                              └──────────────────┘
```

## Documentation

- [Flux Kustomization](https://fluxcd.io/flux/components/kustomize/kustomizations/)
- [Flux GitRepository](https://fluxcd.io/flux/components/source/gitrepositories/)
- [Health Checks](https://fluxcd.io/flux/components/kustomize/kustomizations/#health-assessment)

## Think About

- Why separate GitRepository from Kustomization? (reuse, multiple paths)
- What if you want different sync intervals for different apps?
- How would you deploy to multiple namespaces from one Kustomization?

## When You're Done

Update `PROGRESS.md`:
- Change task 08-fluxcd-first-app status to ✅
- Unlock task 09-fluxcd-workflow
- Note: Prune setting, health checks enabled?
