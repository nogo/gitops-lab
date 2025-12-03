# Task 09b: Image Automation (FluxCD Path — Bonus)

## Objective

Experience FluxCD's built-in image automation — the key differentiator from ArgoCD. Flux can automatically update image tags in Git when new versions are pushed to a container registry.

## The Problem This Solves

Traditional GitOps flow:
1. CI builds image → pushes `myapp:v1.2.3` to registry
2. **Manual step**: Someone updates Git manifest to reference `v1.2.3`
3. GitOps controller syncs

FluxCD automation:
1. CI builds image → pushes `myapp:v1.2.3` to registry
2. **Flux detects new tag** → updates Git manifest → commits
3. Flux syncs the change it just made

Git remains the source of truth, but Flux automates the "update the tag" step.

## What You'll Build

```
clusters/dev/
├── flux-system/
├── apps.yaml                    # Existing
└── image-automation/            # NEW
    ├── image-repository.yaml    # Scan registry for tags
    ├── image-policy.yaml        # Select which tag to use
    └── image-update.yaml        # Commit changes to Git
```

## Prerequisites

- Image automation controllers installed (from bootstrap with `--components-extra`)
- A container image to track (we'll use a public image for this lab)

## Success Criteria

- [ ] ImageRepository scanning a registry
- [ ] ImagePolicy selecting tags based on semver
- [ ] ImageUpdateAutomation configured
- [ ] Manifest has image policy marker
- [ ] Flux automatically updates image tag in Git
- [ ] You understand the three CRDs and their roles

## Key Concepts

### Three CRDs Working Together

| CRD | Purpose | Analogy |
|-----|---------|---------|
| `ImageRepository` | Scans registry for available tags | "What versions exist?" |
| `ImagePolicy` | Selects which tag to use | "Which version do I want?" |
| `ImageUpdateAutomation` | Commits changes to Git | "Update the manifest" |

### Image Policy Marker

You mark which images in your manifests should be auto-updated:
```yaml
image: nginx:1.25.0 # {"$imagepolicy": "flux-system:nginx"}
```

Flux finds these markers and updates the tag.

## Hints

<details>
<summary>Hint 1 — Check Controllers Installed</summary>

```bash
flux check

# Should show:
# ✔ image-reflector-controller: healthy
# ✔ image-automation-controller: healthy
```

If missing, re-bootstrap with:
```bash
flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=gitops-lab \
  --branch=main \
  --path=./clusters/dev \
  --personal \
  --components-extra=image-reflector-controller,image-automation-controller
```

</details>

<details>
<summary>Hint 2 — ImageRepository</summary>

```yaml
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImageRepository
metadata:
  name: nginx
  namespace: flux-system
spec:
  image: library/nginx
  interval: 5m
```

This scans Docker Hub for nginx tags every 5 minutes.

For private registries, add:
```yaml
spec:
  secretRef:
    name: regcred
```

</details>

<details>
<summary>Hint 3 — ImagePolicy</summary>

```yaml
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImagePolicy
metadata:
  name: nginx
  namespace: flux-system
spec:
  imageRepositoryRef:
    name: nginx
  policy:
    semver:
      range: 1.25.x
```

This selects the latest `1.25.x` version (e.g., `1.25.3`).

Other policy options:
- `semver: { range: ">=1.0.0" }` — latest semver
- `numerical: { order: asc }` — latest number
- `alphabetical: { order: asc }` — alphabetically

</details>

<details>
<summary>Hint 4 — Mark Your Manifest</summary>

Update `apps/base/nginx/deployment.yaml`:
```yaml
spec:
  containers:
    - name: nginx
      image: nginx:1.25.0 # {"$imagepolicy": "flux-system:nginx"}
```

The comment is a **marker** — Flux finds it and updates the tag.

</details>

<details>
<summary>Hint 5 — ImageUpdateAutomation</summary>

```yaml
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImageUpdateAutomation
metadata:
  name: flux-system
  namespace: flux-system
spec:
  interval: 30m
  sourceRef:
    kind: GitRepository
    name: flux-system
  git:
    checkout:
      ref:
        branch: main
    commit:
      author:
        email: flux@gitops-lab.local
        name: Flux
      messageTemplate: |
        Automated image update
        
        {{range .Changed.Changes}}
        - {{.OldValue}} -> {{.NewValue}}
        {{end}}
    push:
      branch: main
  update:
    path: ./apps
    strategy: Setters
```

</details>

## Step-by-Step

### 1. Verify Controllers

```bash
flux check
# Ensure image-reflector-controller and image-automation-controller are healthy
```

### 2. Create ImageRepository

```yaml
# clusters/dev/image-automation/image-repository.yaml
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImageRepository
metadata:
  name: nginx
  namespace: flux-system
spec:
  image: library/nginx
  interval: 5m
```

### 3. Create ImagePolicy

```yaml
# clusters/dev/image-automation/image-policy.yaml
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImagePolicy
metadata:
  name: nginx
  namespace: flux-system
spec:
  imageRepositoryRef:
    name: nginx
  policy:
    semver:
      range: 1.25.x
```

### 4. Mark Your Deployment

Update `apps/base/nginx/deployment.yaml`:
```yaml
      containers:
        - name: nginx
          image: nginx:1.25.0 # {"$imagepolicy": "flux-system:nginx"}
```

### 5. Create ImageUpdateAutomation

```yaml
# clusters/dev/image-automation/image-update.yaml
apiVersion: image.toolkit.fluxcd.io/v1beta2
kind: ImageUpdateAutomation
metadata:
  name: flux-system
  namespace: flux-system
spec:
  interval: 10m
  sourceRef:
    kind: GitRepository
    name: flux-system
  git:
    checkout:
      ref:
        branch: main
    commit:
      author:
        email: flux@gitops-lab.local
        name: Flux
      messageTemplate: |
        Automated image update
        
        {{range .Changed.Changes}}
        - {{.OldValue}} -> {{.NewValue}}
        {{end}}
    push:
      branch: main
  update:
    path: ./apps
    strategy: Setters
```

### 6. Commit and Push Everything

```bash
git add .
git commit -m "Add image automation"
git push
```

### 7. Watch the Magic

```bash
# Check ImageRepository is scanning
flux get image repository nginx

# Check ImagePolicy found a tag
flux get image policy nginx

# Watch for automation commits
flux get image update

# Check Git log for Flux commits
git pull
git log --oneline
```

## Validation Commands

```bash
# List all image resources
flux get images all

# Detailed ImageRepository status
kubectl describe imagerepository nginx -n flux-system

# Detailed ImagePolicy status (shows selected tag)
kubectl describe imagepolicy nginx -n flux-system

# Check ImageUpdateAutomation
kubectl describe imageupdateautomation flux-system -n flux-system

# See if Flux made commits
git log --oneline --author="Flux"
```

## Expected Output

```
$ flux get image repository nginx
NAME   LAST SCAN                 SUSPENDED  READY  MESSAGE
nginx  2024-01-15T10:30:00Z      False      True   successful scan: found 50 tags

$ flux get image policy nginx
NAME   LATEST IMAGE    READY  MESSAGE
nginx  nginx:1.25.3    True   Latest image tag for 'library/nginx' resolved to 1.25.3
```

## Common Pitfalls

| Issue | Cause | Resolution |
|-------|-------|------------|
| Controllers missing | Bootstrap without `--components-extra` | Re-bootstrap with image controllers |
| "no tags found" | Wrong image name | Use full path: `library/nginx` for Docker Hub |
| Marker not found | Wrong comment syntax | Must be `# {"$imagepolicy": "namespace:name"}` |
| No commits appearing | Git auth issue | Check ImageUpdateAutomation for errors |
| Wrong tag selected | Policy too broad/narrow | Adjust semver range |

## Security Considerations

- Flux needs **write access** to your Git repo to push commits
- The GITHUB_TOKEN from bootstrap already has this
- In production: use deploy keys or fine-grained PATs
- Consider branch protection with signed commits

## ArgoCD Comparison

| Feature | FluxCD | ArgoCD |
|---------|--------|--------|
| Image automation | Built-in (3 CRDs) | Separate project (Argo Image Updater) |
| Git commits | Native | Requires additional setup |
| Registry scanning | ImageRepository | External component |
| Maturity | Production-ready | Less mature |

This is why you explored FluxCD — the image-to-Git loop is a first-class feature.

## Documentation

- [Flux Image Automation](https://fluxcd.io/flux/guides/image-update/)
- [ImageRepository API](https://fluxcd.io/flux/components/image/imagerepositories/)
- [ImagePolicy API](https://fluxcd.io/flux/components/image/imagepolicies/)
- [ImageUpdateAutomation API](https://fluxcd.io/flux/components/image/imageupdateautomations/)

## Think About

- How would you handle multiple images in one deployment?
- What if you only want automation in staging, not prod?
- How do you prevent bad images from auto-deploying? (policy constraints, testing)

## When You're Done

Update `PROGRESS.md`:
- Change task 09-fluxcd-image-automation status to ✅
- Note: Image automation working, commits appearing in Git
- Ready for Task 10 (Cleanup)
