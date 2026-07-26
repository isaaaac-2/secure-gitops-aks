## Architecture

[Local Dev] --> git push --> [GitHub Repo]
                                    |
                          +---------+---------+
                          |                   |
                   [Terraform]          [Argo CD]
                   provisions           watches repo
                   AKS + ACR            syncs to cluster
                          |                   |
                          v                   v
                    [Azure Infra]      [AKS Cluster]
                    - Resource Group   - App Namespace
                    - AKS Cluster      - Deployments
                    - ACR              - Services
                    - RBAC             - Ingress
                                       - Trivy Gate
                                       - Semgrep Scan
