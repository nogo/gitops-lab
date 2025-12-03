# Task 05: FluxCD Installation

## Objective

Guide the learner to install FluxCD using the CLI bootstrap process. This establishes the GitOps control plane.

## Expected Outcome

- Flux CLI installed locally
- FluxCD running in cluster (`flux-system` namespace)
- Flux configuration committed to Git repo
- Flux managing itself via GitOps

## Success Criteria

Run these to validate completion:

```bash
flux --version
# Must return version

flux check
# All checks must pass

kubectl get pods -n flux-system
# Must show running controllers: source-controller, kustomize-controller, helm-controller, notification-controller

flux get sources git
# Must show flux-system GitRepository

flux get kustomizations
# Must show flux-system Kustomization
```

Additionally, learner should explain the bootstrap concept (Flux installs itself AND commits config to Git).

## Prerequisites

- GitHub account with Personal Access Token (PAT)
- Token needs `repo` scope

## Key Decisions to Guide

1. **Git provider** — GitHub is most common; GitLab also supported
2. **Repository** — Use existing repo (the lab repo)
3. **Path** — `./clusters/dev` is conventional
4. **Components** — Include image automation controllers for Task 09b

## Hint Levels

### Level 1 — Direction
"Flux uses a bootstrap command that both installs Flux AND sets up Git sync. Start by installing the Flux CLI."

### Level 2 — Concept
"Bootstrap is idempotent — it installs Flux controllers to the cluster AND commits the Flux config back to your Git repo. Flux then manages itself via GitOps.

You'll need a GitHub Personal Access Token with `repo` scope."

### Level 3 — Structure
"CLI installation:
- macOS: `brew install fluxcd/tap/flux`
- Linux: `curl -s https://fluxcd.io/install.sh | sudo bash`

Before bootstrap, run `flux check --pre` to verify cluster readiness.

Bootstrap needs: `--owner`, `--repository`, `--branch`, `--path`, `--personal`"

### Level 4 — Pseudocode
```bash
# Install CLI
brew install fluxcd/tap/flux

# Set credentials
export GITHUB_TOKEN=<your-token>
export GITHUB_USER=<your-username>

# Pre-flight check
flux check --pre

# Bootstrap (with image automation for later tasks)
flux bootstrap github \
  --owner=$GITHUB_USER \
  --repository=gitops-lab \
  --branch=main \
  --path=./clusters/dev \
  --personal \
  --components-extra=image-reflector-controller,image-automation-controller
```

### Level 5 — Review
If learner has issues, check:
- Is GITHUB_TOKEN exported? (`echo $GITHUB_TOKEN`)
- Does token have `repo` scope?
- Is kubectl configured for the cluster?
- Check `flux logs` for controller errors

## What Bootstrap Creates

In Git:
```
clusters/
└── dev/
    └── flux-system/
        ├── gotk-components.yaml    # Flux controller manifests (DO NOT EDIT)
        ├── gotk-sync.yaml          # GitRepository + Kustomization for self-management
        └── kustomization.yaml      # Kustomize entry point
```

In cluster:
- `flux-system` namespace
- Source controller, Kustomize controller, Helm controller, Notification controller
- (If --components-extra) Image reflector controller, Image automation controller

## Common Pitfalls

| Error | Cause | Hint to Give |
|-------|-------|--------------|
| "authentication required" | Missing/invalid GITHUB_TOKEN | "Is your GitHub token exported and valid?" |
| "repository not found" | Wrong owner/repo | "Double-check the repository name and owner" |
| "cluster unreachable" | kubectl not configured | "Can you run `kubectl get nodes`?" |
| Bootstrap hangs | Git push failing | "Check your token has write permissions to the repo" |

## Documentation Links

- [Flux Installation](https://fluxcd.io/flux/installation/)
- [Bootstrap for GitHub](https://fluxcd.io/flux/installation/bootstrap/github/)
- [Flux CLI Reference](https://fluxcd.io/flux/cmd/)

## ArgoCD Comparison

If learner asks how ArgoCD differs:

| Aspect | FluxCD | ArgoCD |
|--------|--------|--------|
| Installation | CLI bootstrap (self-managing) | Helm/manifests via Terraform |
| Self-management | Yes, via GitOps | No, managed externally |
| Config location | Committed to Git automatically | Manual or Helm values |
| Upgrade process | Re-run bootstrap | Helm upgrade |

## On Completion

Update PROGRESS.md:
- Set task 05 status to ✅
- Add notes: bootstrap path, components installed
