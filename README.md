# Amazon EKS GitOps Platform with Terraform

Project 2 builds a production-oriented internal Kubernetes platform on Amazon EKS and deploys a three-tier application through GitOps.

The project demonstrates infrastructure as code, Kubernetes platform engineering, container security, software supply-chain controls, AWS identity, observability, automated delivery and rollback.

## Repository model

The platform is separated into three repositories with different ownership responsibilities.

| Repository | Responsibility |
|---|---|
| `terraform-aws-eks-gitops-platform` | Provisions AWS infrastructure, EKS and initial platform add-ons |
| `three-tier-eks-application` | Stores frontend and backend source code, tests and container build definitions |
| `three-tier-eks-gitops` | Stores the desired Kubernetes and Helm application configuration watched by Argo CD |

Repositories:

- [Infrastructure repository](https://github.com/TechWorld707/terraform-aws-eks-gitops-platform)
- [Application repository](https://github.com/TechWorld707/three-tier-eks-application)
- [GitOps repository](https://github.com/TechWorld707/three-tier-eks-gitops)

## Architecture ownership

Terraform provisions and manages:

- VPC
- public and private subnets
- routing and NAT gateways
- VPC endpoints
- EKS control plane
- EKS managed node groups
- ECR repositories
- KMS keys
- IAM roles and policies
- EKS Pod Identity or IRSA
- AWS-managed EKS add-ons
- initial platform bootstrap

The separate add-ons Terraform state initially installs:

- Argo CD
- AWS Load Balancer Controller
- ExternalDNS
- External Secrets Operator
- Metrics Server
- required Kubernetes namespaces
- selected autoscaling prerequisites

After Argo CD is operational, GitOps manages:

- frontend workloads
- API workloads
- Kubernetes Services
- Ingress resources
- ConfigMaps
- Horizontal Pod Autoscalers
- NetworkPolicies
- application image digests
- application updates and rollbacks

## State separation

The development environment uses separate Terraform roots:

```text
environments/dev/foundation
environments/dev/addons