# Terraform state separation

## Decision

Project 2 uses separate Terraform states for:

1. The AWS and EKS foundation.
2. The Kubernetes and Helm add-ons.

The development roots are:

- `environments/dev/foundation`
- `environments/dev/addons`

## Foundation state ownership

The foundation state manages resources that must exist before Terraform can communicate with Kubernetes:

- VPC
- public subnets
- private subnets
- internet gateway
- NAT gateways
- route tables
- VPC endpoints
- security groups
- EKS control plane
- EKS access entries
- managed node groups
- ECR repositories
- KMS keys
- AWS IAM roles and policies
- GitHub Actions AWS authentication

The foundation state uses the AWS provider. It creates the cluster endpoint and identity information needed by the add-ons layer.

## Add-ons state ownership

The add-ons state manages the initial platform services installed into the existing EKS cluster:

- Argo CD
- AWS Load Balancer Controller
- ExternalDNS
- External Secrets Operator
- Metrics Server
- Karpenter controller prerequisites
- supporting Kubernetes namespaces
- required Helm releases

The add-ons state uses AWS, Kubernetes and Helm providers. It reads the foundation outputs through Terraform remote state.

## Why the states are separated

The Kubernetes and Helm providers require a reachable EKS API endpoint and valid cluster authentication during provider initialization.

If the cluster and its add-ons were managed in one state, Terraform could attempt to initialize the Kubernetes or Helm provider before the cluster existed. This creates provider bootstrapping problems and unreliable first-time applies.

Separate states provide a strict dependency sequence:

1. Bootstrap the remote-state infrastructure.
2. Apply the EKS foundation.
3. Read the foundation outputs.
4. Configure Kubernetes and Helm providers.
5. Apply the platform add-ons.

## Blast-radius reduction

A failed Helm release, Kubernetes API error or add-on upgrade must not put the VPC, EKS control plane or node groups at risk.

State separation means:

- add-on failures remain inside the add-ons state;
- foundation plans cannot accidentally modify Helm releases;
- add-on plans cannot accidentally replace foundational AWS resources;
- permissions can be different for foundation and add-on pipelines;
- recovery and rollback procedures can be performed independently.

## State dependency

The add-ons configuration reads selected foundation outputs, including:

- AWS Region
- EKS cluster name
- EKS cluster endpoint
- EKS certificate-authority data
- cluster OIDC or Pod Identity information
- private subnet IDs
- workload IAM role ARNs

The add-ons state consumes these outputs but does not own the underlying AWS resources.

## Apply order

The required apply order is:

1. `bootstrap`
2. `environments/dev/foundation`
3. `environments/dev/addons`

Application deployment begins only after Argo CD is healthy.

## Destroy order

The safe destroy order is the reverse:

1. Remove Argo CD applications and application workloads.
2. Destroy `environments/dev/addons`.
3. Destroy `environments/dev/foundation`.
4. Retain the bootstrap state infrastructure unless the entire platform is being permanently retired.

Destroying the foundation before add-ons can leave Kubernetes and Helm resources unreachable and still recorded in Terraform state.

## GitOps ownership boundary

Terraform bootstraps Argo CD but does not continuously manage application Deployments, Services or Ingress resources.

After bootstrap:

- Terraform manages AWS infrastructure and initial platform add-ons.
- Argo CD manages application Kubernetes resources from the GitOps repository.
- GitHub Actions builds and publishes immutable container images.
- The GitOps repository records the desired image digest.