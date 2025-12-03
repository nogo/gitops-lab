# Task 09: GitOps Workflow

## Objective

Experience the full GitOps workflow: make a change in Git, watch ArgoCD detect and apply it. This is the "magic" of GitOps.

## What You'll Do

1. Modify the nginx configuration in Git
2. Push the change
3. Observe ArgoCD detect the drift
4. Watch (or trigger) the sync
5. Verify the change in the cluster

## Success Criteria

- [ ] Made a meaningful change in Git (not just a comment)
- [ ] ArgoCD detected the change (shows OutOfSync)
- [ ] Change was applied to cluster
- [ ] You observed the workflow end-to-end
- [ ] Bonus: Tested self-heal by making manual kubectl change

## Exercises

### Exercise 1: Scale the Deployment

**Goal:** Change replica count from 1 to 3

1. Create an overlay patch or modify base
2. Commit and push
3. Observe ArgoCD → Sync → Verify pods

### Exercise 2: Update nginx Version

**Goal:** Change nginx image tag from `1.25` to `1.26`

1. Modify deployment manifest
2. Commit and push
3. Watch rolling update

### Exercise 3: Add a ConfigMap

**Goal:** Add configuration to nginx

1. Create `configmap.yaml` in base
2. Add to `kustomization.yaml`
3. Mount in deployment
4. Push and sync

### Exercise 4: Test Self-Heal (if enabled)

**Goal:** Verify ArgoCD reverts manual changes

1. `kubectl scale deployment nginx --replicas=5 -n dev`
2. Watch ArgoCD revert it back to Git state
3. Understand why this matters

## Hints

<details>
<summary>Hint 1 — Scaling with Kustomize</summary>

In your overlay, add a patch:

```yaml
# apps/overlays/dev/kustomization.yaml
patches:
  - patch: |-
      - op: replace
        path: /spec/replicas
        value: 3
    target:
      kind: Deployment
      name: nginx
```

Or use a `replicas` field in kustomization.yaml (simpler).

</details>

<details>
<summary>Hint 2 — Image Update</summary>

Kustomize has `images` transformer:

```yaml
# apps/overlays/dev/kustomization.yaml
images:
  - name: nginx
    newTag: "1.26"
```

</details>

<details>
<summary>Hint 3 — Watching Sync</summary>

```bash
# Watch application status
argocd app get nginx-dev --refresh

# Watch pods
kubectl get pods -n dev -w

# ArgoCD refresh (force check)
argocd app get nginx-dev --refresh
```

</details>

<details>
<summary>Hint 4 — Sync History</summary>

```bash
argocd app history nginx-dev
```

Shows all sync operations with revision info.

</details>

<details>
<summary>Hint 5 — Debug OutOfSync</summary>

```bash
# See what's different
argocd app diff nginx-dev

# Detailed resource view
argocd app resources nginx-dev
```

</details>

## Validation Commands

```bash
# Check current state
argocd app get nginx-dev

# Force refresh from Git
argocd app get nginx-dev --refresh

# See diff between Git and cluster
argocd app diff nginx-dev

# Manual sync if needed
argocd app sync nginx-dev

# Watch rollout
kubectl rollout status deployment/nginx -n dev

# Check running version
kubectl get pods -n dev -o jsonpath='{.items[*].spec.containers[*].image}'
```

## GitOps Workflow Diagram

```
┌─────────────┐
│  Developer  │
│  changes    │
│  manifest   │
└──────┬──────┘
       │ git push
       ▼
┌─────────────┐
│   GitHub    │◄──────────────────┐
│   (Git)     │                   │
└──────┬──────┘                   │
       │ poll (3min)              │
       │ or webhook               │
       ▼                          │
┌─────────────┐                   │
│   ArgoCD    │──────compare──────┘
│ Controller  │
└──────┬──────┘
       │ kubectl apply
       ▼
┌─────────────┐
│  Kubernetes │
│  Cluster    │
└─────────────┘
```

## Common Pitfalls

| Issue | Cause | Resolution |
|-------|-------|------------|
| Changes not detected | ArgoCD poll interval (3min) | Force refresh or add webhook |
| OutOfSync but won't sync | Manual sync policy | Click Sync or use CLI |
| Sync failed | Invalid manifests | Check app events in UI/CLI |
| Self-heal not working | Not enabled in syncPolicy | Add `selfHeal: true` |

## This is GitOps

What you just experienced:
- **Git as single source of truth** — Cluster state matches Git
- **Declarative** — You declare desired state, controller reconciles
- **Auditable** — Every change is a Git commit
- **Recoverable** — Roll back = revert commit

Compare to imperative:
```bash
# Old way (imperative, not tracked)
kubectl scale deployment nginx --replicas=3
kubectl set image deployment/nginx nginx=nginx:1.26

# GitOps way (declarative, auditable)
# Edit YAML → commit → push → ArgoCD syncs
```

## Documentation

- [ArgoCD Sync Options](https://argo-cd.readthedocs.io/en/stable/user-guide/sync-options/)
- [ArgoCD Tracking Strategies](https://argo-cd.readthedocs.io/en/stable/user-guide/tracking_strategies/)
- [Kustomize Images](https://kubectl.docs.kubernetes.io/references/kustomize/kustomization/images/)

## Think About

- How would you implement a rollback?
- What if a bad change breaks the app?
- How do you handle secrets that can't go in Git?

## When You're Done

Update `PROGRESS.md`:
- Change task 09 status to ✅
- Unlock task 10
- Note: What exercises you completed, observations
