# Task 08: First Application

## Objective

Create an ArgoCD Application that deploys your nginx app from Git. This is where infrastructure meets GitOps.

## What You'll Build

```
argocd/
└── applications/
    └── nginx-dev.yaml    # ArgoCD Application CRD
```

## Success Criteria

- [ ] ArgoCD Application resource created
- [ ] Application visible in ArgoCD UI
- [ ] nginx pods running in `dev` namespace
- [ ] Application shows "Synced" and "Healthy" status
- [ ] You can explain what the Application CRD does

## Key Decisions You Must Make

1. **Git source:** Local path vs remote repo?
2. **Sync policy:** Manual vs Auto-sync?
3. **Prune:** Delete resources removed from Git?
4. **Self-heal:** Revert manual cluster changes?

## Challenge: Local Git Repository

ArgoCD needs to pull from a Git repo. Options for this lab:

**Option A:** Push to GitHub/GitLab (simplest for ArgoCD)
**Option B:** Local Git server (complex, not worth it)
**Option C:** Use ArgoCD's directory-based source (filesystem, limited)

**Recommendation:** Create a GitHub repo and push your `apps/` folder. ArgoCD will poll it.

## Hints

<details>
<summary>Hint 1 — Application CRD</summary>

ArgoCD uses a custom resource called `Application` in the `argocd` namespace.

Key fields: `source` (where to get manifests), `destination` (where to deploy), `syncPolicy`.

</details>

<details>
<summary>Hint 2 — Minimal Application</summary>

```yaml
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: nginx-dev
  namespace: argocd
spec:
  project: default
  source:
    repoURL: <your-git-repo-url>
    targetRevision: HEAD
    path: apps/overlays/dev
  destination:
    server: https://kubernetes.default.svc
    namespace: dev
```

</details>

<details>
<summary>Hint 3 — Sync Policy Options</summary>

For auto-sync:
```yaml
syncPolicy:
  automated:
    prune: true      # Delete resources removed from Git
    selfHeal: true   # Revert manual changes
```

For manual sync, omit the `automated` block.

</details>

<details>
<summary>Hint 4 — Apply the Application</summary>

```bash
kubectl apply -f argocd/applications/nginx-dev.yaml
```

Then check ArgoCD UI or:
```bash
argocd app list
argocd app get nginx-dev
```

</details>

<details>
<summary>Hint 5 — Triggering Sync</summary>

If using manual sync:
```bash
argocd app sync nginx-dev
```

Or click "Sync" in the UI.

</details>

## Validation Commands

```bash
# Apply the Application CRD
kubectl apply -f argocd/applications/nginx-dev.yaml

# Check application status
argocd app list
argocd app get nginx-dev

# Wait for sync
argocd app wait nginx-dev --health

# Verify deployment
kubectl get pods -n dev
kubectl get svc -n dev
```

## Expected Output

```
$ argocd app list
NAME       CLUSTER                         NAMESPACE  PROJECT  STATUS  HEALTH   SYNCPOLICY
nginx-dev  https://kubernetes.default.svc  dev        default  Synced  Healthy  Auto

$ kubectl get pods -n dev
NAME                     READY   STATUS    RESTARTS   AGE
nginx-xxxxxxxxx-xxxxx   1/1     Running   0          1m
```

## Common Pitfalls

| Issue | Cause | Resolution |
|-------|-------|------------|
| "repository not found" | Wrong repoURL or no access | Check URL; for private repos, add credentials |
| "path does not exist" | Wrong path in source | Verify path matches repo structure |
| "namespace not found" | Namespace not created | Add namespace to Kustomize or pre-create |
| "OutOfSync" forever | Sync policy set to manual | Click Sync or set automated |
| "ComparisonError" | Invalid manifests in Git | Run `kubectl kustomize` locally to debug |

## Application Lifecycle

```
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│   Git Repo   │ ──▶│   ArgoCD     │ ──▶│   Cluster    │
│ (Desired)    │    │ (Controller) │    │   (Actual)   │
└──────────────┘    └──────────────┘    └──────────────┘
                           │
                    Compares & Syncs
```

1. You push to Git (desired state)
2. ArgoCD detects change (polls every 3min or webhook)
3. ArgoCD compares desired vs actual
4. ArgoCD syncs (applies manifests)
5. ArgoCD reports health status

## Documentation

- [ArgoCD Application Spec](https://argo-cd.readthedocs.io/en/stable/operator-manual/declarative-setup/)
- [Sync Policies](https://argo-cd.readthedocs.io/en/stable/user-guide/auto_sync/)
- [ArgoCD Projects](https://argo-cd.readthedocs.io/en/stable/user-guide/projects/)

## Think About

- What happens if you delete the Application CRD?
- How would you handle multiple apps with similar configs?
- When would you NOT want auto-sync?

## When You're Done

Update `PROGRESS.md`:
- Change task 08 status to ✅
- Unlock task 09
- Note: Git repo URL, sync policy choice
