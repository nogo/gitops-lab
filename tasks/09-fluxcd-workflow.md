# Task 09: GitOps Workflow (FluxCD Path)

## Objective

Experience the full GitOps workflow with FluxCD: make a change in Git, watch Flux detect and apply it. Same concept as ArgoCD, different commands.

## What You'll Do

1. Modify nginx configuration in Git
2. Push the change
3. Observe Flux detect the change
4. Watch the reconciliation
5. Verify the change in the cluster

## Success Criteria

- [ ] Made a meaningful change in Git (not just a comment)
- [ ] Flux detected the change
- [ ] Change was applied to cluster
- [ ] You observed the workflow end-to-end
- [ ] Tested drift correction (manual kubectl change reverted)

## Exercises

### Exercise 1: Scale the Deployment

**Goal:** Change replica count from 1 to 3

1. Modify `apps/base/nginx/deployment.yaml` or add a patch in overlay
2. Commit and push
3. Watch: `flux get kustomizations --watch`
4. Verify: `kubectl get pods -n development`

### Exercise 2: Update nginx Version

**Goal:** Change nginx image tag

1. Modify deployment or use Kustomize `images` transformer
2. Commit and push
3. Watch rolling update: `kubectl rollout status deployment/nginx -n development`

### Exercise 3: Test Drift Correction

**Goal:** Verify Flux reverts manual changes

1. Scale manually: `kubectl scale deployment nginx --replicas=5 -n development`
2. Wait for Flux reconciliation (or trigger: `flux reconcile kustomization apps`)
3. Watch pods scale back to Git-defined count

## Hints

<details>
<summary>Hint 1 — Force Reconciliation</summary>

Don't want to wait for the interval?
```bash
# Trigger source fetch
flux reconcile source git flux-system

# Trigger kustomization apply
flux reconcile kustomization apps
```

</details>

<details>
<summary>Hint 2 — Watch Everything</summary>

```bash
# In one terminal: watch Flux
flux get kustomizations --watch

# In another: watch pods
kubectl get pods -n development -w

# Or use flux logs
flux logs --follow
```

</details>

<details>
<summary>Hint 3 — Scaling with Kustomize</summary>

In your overlay `kustomization.yaml`:
```yaml
replicas:
  - name: nginx
    count: 3
```

Or use a JSON patch.

</details>

<details>
<summary>Hint 4 — Image Update with Kustomize</summary>

In your overlay `kustomization.yaml`:
```yaml
images:
  - name: nginx
    newTag: "1.26"
```

</details>

<details>
<summary>Hint 5 — Check Revision</summary>

```bash
# See which Git commit is deployed
flux get kustomization apps

# Compare to your local
git log --oneline -1
```

The REVISION column shows `branch@sha1:commit`.

</details>

## Validation Commands

```bash
# Check current state
flux get kustomizations

# Force sync
flux reconcile kustomization apps

# Watch pods
kubectl get pods -n development -w

# Check deployment details
kubectl describe deployment nginx -n development

# View rollout history
kubectl rollout history deployment/nginx -n development
```

## Expected Flow

```
You: git commit && git push
            │
            ▼ (interval or manual reconcile)
┌───────────────────────────────────┐
│ source-controller                 │
│  - Fetches new commit from Git    │
│  - Updates artifact               │
└─────────────┬─────────────────────┘
              │
              ▼
┌───────────────────────────────────┐
│ kustomize-controller              │
│  - Detects new artifact revision  │
│  - Runs kustomize build           │
│  - Applies to cluster             │
└─────────────┬─────────────────────┘
              │
              ▼
┌───────────────────────────────────┐
│ Kubernetes                        │
│  - Creates/updates resources      │
│  - Rolling update if needed       │
└───────────────────────────────────┘
```

## Drift Correction

When `prune: true` is set, Flux will:
- **Delete** resources removed from Git
- **Revert** manual changes to match Git

This is GitOps enforcement — the cluster converges to Git state.

```
Manual change: kubectl scale replicas=5
                    │
                    ▼
Flux interval: (checks Git, sees replicas=1)
                    │
                    ▼
Flux action: scales back to 1
```

## Common Pitfalls

| Issue | Cause | Resolution |
|-------|-------|------------|
| Changes not applying | Didn't push to correct branch | Check `targetRevision` in GitRepository |
| "revision unchanged" | Flux already has that commit | Push a new commit |
| Drift not corrected | `prune: true` not set | Update Kustomization spec |
| Slow sync | Default interval is 5m+ | `flux reconcile` or reduce interval |

## This is GitOps

What you experienced:
- **Git as single source of truth**
- **Declarative** — state in Git, controller reconciles
- **Auditable** — every change is a commit
- **Self-healing** — drift is corrected automatically

## Documentation

- [Flux Reconciliation](https://fluxcd.io/flux/components/kustomize/kustomizations/#reconciliation)
- [Flux CLI reconcile](https://fluxcd.io/flux/cmd/flux_reconcile/)

## Think About

- How would you implement a rollback?
- What if a change breaks the app — how do you detect and respond?
- How does Flux's interval-based polling compare to ArgoCD's?

## When You're Done

Update `PROGRESS.md`:
- Change task 09-fluxcd-workflow status to ✅
- Unlock task 09-fluxcd-image-automation
- Note: Exercises completed, drift correction tested
