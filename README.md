# GitOps Learning Lab

A hands-on lab for learning GitOps with Terraform, Kubernetes, and your choice of ArgoCD or FluxCD, guided by AI.

## What You'll Learn

- **Terraform fundamentals** — Provision cloud infrastructure as code
- **Kubernetes cluster setup** — Deploy a managed Kubernetes cluster
- **GitOps workflows** — Declarative deployments with ArgoCD or FluxCD
- **Drift detection and reconciliation** — Self-healing infrastructure

## How This Lab Works

This lab is designed to be completed with an AI tutor (Claude). The AI guides you through each task using the Socratic method — asking questions, providing hints, and validating your work rather than giving you answers directly.

**You will:**
- Chat with the AI in your terminal or editor
- Write real Terraform and Kubernetes manifests
- Deploy to a real cloud cluster
- Learn by doing, not copy-pasting

## Prerequisites

### Required
- Git and a GitHub account
- Terraform CLI installed
- kubectl installed
- A cloud provider account (Azure or AWS)

### Cloud Provider CLI
- **Azure:** [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed and authenticated (`az login`)
- **AWS:** [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/getting-started-install.html) installed and configured (`aws configure`)

### GitOps Tool CLI (installed during lab)
- **ArgoCD:** `argocd` CLI
- **FluxCD:** `flux` CLI

## Getting Started

1. **Fork this repository** to your GitHub account

2. **Clone your fork locally**
   ```bash
   git clone https://github.com/<your-username>/gitops-lab.git
   cd gitops-lab
   ```

3. **Start a chat session** with Claude, ChatGPT or Gemini (via Claude Code, API, or your preferred interface)

4. **Begin the lab** — The AI will ask you to choose:
   - Your cloud provider (Azure or AWS)
   - Your GitOps tool (ArgoCD or FluxCD)

5. **Follow the AI's guidance** through each task

## Lab Structure

### Foundation Tasks (01-04)
Provider-specific infrastructure setup:
1. Terraform Bootstrap
2. Networking
3. Kubernetes Cluster
4. Cluster Access

### GitOps Tasks (05-09)
Tool-specific GitOps implementation:
5. Install ArgoCD/FluxCD
6. Access and Configuration
7. Repository Structure
8. First Application
9. GitOps Workflow

### Cleanup (10)
Tear down all resources.

## Path Options

| Path | Best For |
|------|----------|
| **Azure + ArgoCD** | UI-first experience, visual learners |
| **Azure + FluxCD** | CLI-native workflow, built-in image automation |
| **AWS + ArgoCD** | EKS experience with visual GitOps |
| **AWS + FluxCD** | EKS with CLI-first GitOps |

## Estimated Time

- Foundation tasks: 1-2 hours
- GitOps tasks: 2-3 hours
- Total: 3-5 hours (depending on experience)

## Cost Warning

This lab creates real cloud resources that incur costs:
- **Azure:** ~$3-5/day for AKS cluster
- **AWS:** ~$3-5/day for EKS cluster

**Always run Task 10 (Cleanup) when done** to destroy resources and stop billing.

## Reference Solutions

Stuck? Reference implementations are available in the `reference/` directory. Use these to compare against your work — not to copy-paste.

## Contributing

Contributions welcome! See areas for contribution:
- Additional cloud provider support (GCP, etc.)
- Task improvements and clarifications
- Reference implementations

## License

MIT
