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
## Development observability

The `environments/dev/addons` stack installs Prometheus, Alertmanager, Grafana,
Blackbox Exporter, Fluent Bit, an OpenTelemetry Collector, and single-binary Tempo.
Apply the add-ons before syncing the GitOps monitoring resources so the Prometheus
Operator CRDs exist. Prometheus and Tempo each request a 10 GiB encrypted gp3
volume. Prometheus retains up to seven days or 8 GB and Tempo retains 48 hours.
Fluent Bit ships logs from `three-tier-dev` to
`/aws/eks/<cluster-name>/three-tier-dev` with 14-day retention. EKS already publishes
control-plane logs to `/aws/eks/<cluster-name>/cluster`. Grafana and Fluent Bit use
EKS Pod Identity for their respective CloudWatch access.

After the application Ingress provisions an ALB, set `observability_alb` with its
ALB and frontend target group ARN suffixes to create the unhealthy-target alarm.
The optional SNS topic must allow CloudWatch to publish and have confirmed subscribers.
For application notifications, create a Secret in `monitoring` with the
`alertmanager.yaml` key and set `observability_alertmanager_config_secret` to its
name. Until a receiver is configured, application alerts are visible in Alertmanager.
