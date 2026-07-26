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

1. Install Docker:
   ``` text
   sudo apt update && sudo apt install -y docker.io
   sudo systemctl enable --now docker
   sudo usermod -aG docker $USER
   newgrp docker
   ```

2. Install kind:
   ``` text 
   curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.24.0/kind-linux-amd64
   chmod +x ./kind
   sudo mv ./kind /usr/local/bin/kind
   ```

3. Install kubectl:
   ``` text
   curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
   chmod +x kubectl
   sudo mv kubectl /usr/local/bin/
   ```
4. Create the cluster:
   ``` text
   kind create cluster --name gitops-security
   ```

5. Create namespace and install Argo CD:
    ``` text
   kubectl create namespace argocd
   kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
    ```

6. Apply the Argo CD application manifest:
   ``` text
   kubectl apply -f argocd/application.yaml
   ```

7. Push changes to GitHub and watch Argo CD auto-sync


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


## Tools & Tech

Argo CD, Trivy, Semgrep, Helm, Kind, Docker, GitHub Actions, Terraform, Kubernetes, Nginx