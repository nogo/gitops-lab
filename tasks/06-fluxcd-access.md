# Task 06: FluxCD Access & Verification (FluxCD Path)

## Objective

Verify FluxCD installation, learn the CLI commands for monitoring, and understand how to observe the GitOps reconciliation loop.

## ArgoCD vs FluxCD: Key Difference

ArgoCD has a rich web UI. FluxCD is **CLI-first** — no built-in UI. You monitor everything via `flux` commands and `kubectl`. Optional UIs like Weave GitOps exist but aren't required.

## What You'll Learn

- Flux CLI commands for status and troubleshooting
- How to watch reconciliation in real-time
- Understanding Flux's resource model (Sources, Kustomizations)

## Success Criteria

- [ ] `flux check` passes all health checks
- [ ] Can list GitRepository sources with `flux get sources git`
- [ ] Can list Kustomizations with `flux get kustomizations`
- [ ] Understand the flux-system self-management loop
- [ ] Can trigger manual reconciliation
- [ ] You understand why there's no UI (and alternatives)

## Key Commands

### Health & Status

```bash
# Overall health check
flux check

# View all Flux resources at once
flux get all

# Detailed view with namespace
flux get all -A
```

### Sources (where Flux pulls from)

```bash
# List Git repositories Flux is watching
flux get sources git

# List Helm repositories (if any)
flux get sources helm

# List OCI repositories (if any)
flux get sources oci
```

### Kustomizations (what Flux deploys)

```bash
# List all Kustomizations
flux get kustomizations

# Watch reconciliation in real-time
flux get kustomizations --watch
```

## Hints

<details>
<summary>Hint 1 — Understanding the Output</summary>

```
$ flux get kustomizations
NAME        REVISION     SUSPENDED  READY  MESSAGE
flux-system main/abc123  False      True   Applied revision: main/abc123
```

- **REVISION**: Git commit being applied
- **SUSPENDED**: If true, reconciliation is paused
- **READY**: Health status
- **MESSAGE**: Last reconciliation result

</details>

<details>
<summary>Hint 2 — Trigger Manual Reconciliation</summary>

Force Flux to check Git immediately (don't wait for interval):
```bash
flux reconcile source git flux-system
flux reconcile kustomization flux-system
```

</details>

<details>
<summary>Hint 3 — View Logs</summary>

```bash
# Source controller logs (Git fetching)
kubectl logs -n flux-system deploy/source-controller

# Kustomize controller logs (applying manifests)
kubectl logs -n flux-system deploy/kustomize-controller

# Or stream all Flux logs
flux logs --all-namespaces
```

</details>

<details>
<summary>Hint 4 — Inspect Resources</summary>

```bash
# Detailed view of a GitRepository
kubectl describe gitrepository flux-system -n flux-system

# Detailed view of a Kustomization
kubectl describe kustomization flux-system -n flux-system
```

</details>

<details>
<summary>Hint 5 — Optional UI (Weave GitOps)</summary>

If you want a UI, Weave GitOps is the most common:
```bash
# Install via Flux
flux create source helm weaveworks \
  --url=https://helm.gitops.weave.works

flux create helmrelease weave-gitops \
  --source=HelmRepository/weaveworks \
  --chart=weave-gitops
```

But for this lab, CLI is sufficient.

</details>

## Validation Commands

```bash
# Full status check
flux check

# List all sources
flux get sources git

# List all kustomizations  
flux get kustomizations

# Watch for changes (Ctrl+C to exit)
flux get kustomizations --watch

# Check events
kubectl get events -n flux-system --sort-by='.lastTimestamp'
```

## Expected Output

```
$ flux get sources git
NAME        REVISION          SUSPENDED  READY  MESSAGE
flux-system main@sha1:abc123  False      True   stored artifact for revision 'main@sha1:abc123'

$ flux get kustomizations
NAME        REVISION          SUSPENDED  READY  MESSAGE
flux-system main@sha1:abc123  False      True   Applied revision: main@sha1:abc123
```

## The Self-Management Loop

After bootstrap, Flux watches its own Git repository:

```
┌─────────────────────────────────────────────────────────┐
│ Git Repository (your gitops-lab repo)                   │
│  └── clusters/dev/flux-system/                          │
│       ├── gotk-components.yaml  (Flux controllers)      │
│       └── gotk-sync.yaml        (GitRepo + Kustomization)│
└────────────────────────┬────────────────────────────────┘
                         │ Flux watches this
                         ▼
┌─────────────────────────────────────────────────────────┐
│ Flux Controllers (in flux-system namespace)             │
│  └── Applies manifests from Git to itself               │
└─────────────────────────────────────────────────────────┘
```

To upgrade Flux: update the manifests in Git → Flux applies them → Flux upgrades itself.

## Common Pitfalls

| Issue | Cause | Resolution |
|-------|-------|------------|
| "READY: False" | Reconciliation failed | Check MESSAGE column; `kubectl describe` the resource |
| "repository not found" | Git auth issue | Check GitRepository secret |
| Stuck "reconciling" | Large repo or slow network | Wait, or check source-controller logs |
| No output from `flux get` | Wrong namespace | Use `-A` for all namespaces |

## Documentation

- [Flux CLI Reference](https://fluxcd.io/flux/cmd/)
- [Monitoring with Flux](https://fluxcd.io/flux/monitoring/)
- [Weave GitOps (optional UI)](https://docs.gitops.weave.works/)

## Think About

- Why might a CLI-first approach be preferable for some teams?
- How would you integrate Flux status into a CI/CD dashboard?
- What's the trade-off between no UI and operational visibility?

## When You're Done

Update `PROGRESS.md`:
- Change task 06-fluxcd-access status to ✅
- Unlock task 07-fluxcd-repo
- Note: Key commands learned, any issues encountered
