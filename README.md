# Secure GitOps AKS Pipeline

A security-first GitOps pipeline demonstrating automated deployment with Argo CD, pre-deploy vulnerability scanning (Trivy), SAST misconfiguration detection (Semgrep), and container hardening on a local Kubernetes cluster.

Architecture

GitHub Repo → GitHub Actions (Trivy + Semgrep) → Argo CD (auto-sync) → Kind Cluster (hardened nginx)

## Security Controls

- Trivy image scanning gates deploys on HIGH/CRITICAL vulnerabilities
- Semgrep SAST catches K8s manifest misconfigs before sync
- Container securityContext: runAsNonRoot, readOnlyRootFilesystem, no privilege escalation
- Unprivileged nginx base image (nginxinc/nginx-unprivileged)
- Argo CD automated sync with prune and self-heal enabled

## Local Setup

1. Install kind, kubectl, Docker
2. kind create cluster --name gitops-security
3. Install Argo CD: kubectl apply -n argocd -f install.yaml
4. Apply argocd/application.yaml pointing to this repo
5. Push changes and watch Argo CD auto-sync

## Production Hardening (Next Steps)

- RBAC policies for Argo CD access control
- NetworkPolicies to restrict pod-to-pod traffic
- Sealed Secrets or External Secrets Operator for secret management
- OPA/Gatekeeper for policy enforcement at admission
- Azure AKS deployment once subscription quota is unlocked


## Architecture
```text
Local Dev
     |
     v
git push --> [GitHub Repo: secure-gitops-aks]
                  |
      +-----------+-----------+
      |                       |
[Terraform]            [GitHub Actions]
provisions             - Trivy image scan
- Azure RG             - Semgrep SAST
- AKS Cluster          - Pass/Fail gate
- ACR                        |
- RBAC                       v
      |               [Argo CD]
      v               watches repo
[Azure Infra]         auto-syncs manifests
- Resource Group            |
- AKS Cluster               v
- ACR                 [K8s Cluster]
- RBAC                - Hardened nginx
                      - securityContext
                      - unprivileged image
                      - Trivy gate enforced
                      - Semgrep scan enforced
```
