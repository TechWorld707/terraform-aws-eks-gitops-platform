mock_provider "kubernetes" {}

mock_provider "helm" {}

mock_provider "aws" {
  override_during = plan

  mock_data "aws_partition" {
    defaults = {
      partition  = "aws"
      dns_suffix = "amazonaws.com"
    }
  }

  mock_data "aws_iam_policy_document" {
    defaults = {
      json = "{\"Version\":\"2012-10-17\",\"Statement\":[]}"
    }
  }
}

run "development_addons" {
  command = plan

  variables {
    aws_region   = "us-east-1"
    project_name = "three-tier-eks"
    environment  = "dev"

    foundation_state_bucket = "terraform-state-test"
    foundation_state_key    = "eks-gitops/dev/foundation/terraform.tfstate"

    external_dns_hosted_zone_ids = [
      "Z0123456789ABCDEF"
    ]

    external_dns_domain_filters = [
      "dev.example.com"
    ]

    external_secrets_secret_arns = [
      "arn:aws:secretsmanager:us-east-1:123456789012:secret:three-tier-eks/dev/database-AbCdEf"
    ]

    external_secrets_kms_key_arns = [
      "arn:aws:kms:us-east-1:123456789012:key/1234abcd-12ab-34cd-56ef-1234567890ab"
    ]
  }

  override_data {
    target = data.terraform_remote_state.foundation

    values = {
      outputs = {
        vpc_id           = "vpc-0123456789abcdef0"
        eks_cluster_name = "three-tier-eks-dev"

        eks_cluster_endpoint = (
          "https://example.eks.us-east-1.amazonaws.com"
        )

        eks_cluster_certificate_authority_data = (
          "dGVzdC1jZXJ0aWZpY2F0ZS1hdXRob3JpdHk="
        )
      }
    }
  }

  assert {
    condition = (
      data.terraform_remote_state.foundation.outputs.eks_cluster_name ==
      "three-tier-eks-dev"
    )

    error_message = "The add-ons state must read the expected foundation cluster name."
  }

  assert {
    condition = (
      module.addons.addon_names["pod_identity_agent"] ==
      "eks-pod-identity-agent"
    )

    error_message = "The development add-ons state must install the Pod Identity Agent."
  }

  assert {
    condition     = length(module.addons.addon_names) == 6
    error_message = "The development add-ons state must install six EKS add-ons."
  }

  assert {
    condition = (
      contains(values(module.addons.addon_names), "vpc-cni") &&
      contains(values(module.addons.addon_names), "coredns") &&
      contains(values(module.addons.addon_names), "kube-proxy") &&
      contains(values(module.addons.addon_names), "aws-ebs-csi-driver")
    )

    error_message = "The required networking, DNS, proxy and storage add-ons must be installed."
  }

  assert {
    condition = (
      module.addons.pod_identity_role_names["vpc_cni"] ==
      "three-tier-eks-dev-vpc-cni"
    )

    error_message = "The development VPC CNI Pod Identity role name is incorrect."
  }

  assert {
    condition = (
      module.addons.pod_identity_role_names["ebs_csi"] ==
      "three-tier-eks-dev-ebs-csi"
    )

    error_message = "The development EBS CSI Pod Identity role name is incorrect."
  }

  assert {
    condition = (
      helm_release.aws_load_balancer_controller.name ==
      "aws-load-balancer-controller"
    )

    error_message = "The AWS Load Balancer Controller release name is incorrect."
  }

  assert {
    condition = (
      helm_release.aws_load_balancer_controller.namespace ==
      "kube-system"
    )

    error_message = "The AWS Load Balancer Controller must run in kube-system."
  }

  assert {
    condition = (
      helm_release.aws_load_balancer_controller.chart ==
      "aws-load-balancer-controller"
    )

    error_message = "The expected AWS Load Balancer Controller chart must be installed."
  }

  assert {
    condition = (
      helm_release.aws_load_balancer_controller.version ==
      "1.14.0"
    )

    error_message = "The AWS Load Balancer Controller chart version is incorrect."
  }

  assert {
    condition = (
      yamldecode(
        one(helm_release.aws_load_balancer_controller.values)
      ).clusterName ==
      "three-tier-eks-dev"
    )

    error_message = "The controller must target the development EKS cluster."
  }

  assert {
    condition = (
      yamldecode(
        one(helm_release.aws_load_balancer_controller.values)
      ).vpcId ==
      "vpc-0123456789abcdef0"
    )

    error_message = "The controller must use the development VPC."
  }

  assert {
    condition = (
      yamldecode(
        one(helm_release.aws_load_balancer_controller.values)
      ).serviceAccount.name ==
      "aws-load-balancer-controller"
    )

    error_message = "The controller service-account name is incorrect."
  }

  assert {
    condition = (
      yamldecode(
        one(helm_release.aws_load_balancer_controller.values)
      ).replicaCount ==
      2
    )

    error_message = "The controller must run two replicas."
  }

  assert {
    condition     = helm_release.external_secrets.name == "external-secrets"
    error_message = "The External Secrets Helm release name is incorrect."
  }

  assert {
    condition = (
      helm_release.external_secrets.namespace ==
      "external-secrets"
    )

    error_message = "External Secrets must use its dedicated namespace."
  }

  assert {
    condition = (
      helm_release.external_secrets.chart ==
      "external-secrets"
    )

    error_message = "The official External Secrets chart must be installed."
  }

  assert {
    condition = (
      helm_release.external_secrets.version ==
      var.external_secrets_chart_version
    )

    error_message = "The configured External Secrets chart version must be used."
  }

  assert {
    condition = (
      yamldecode(one(helm_release.external_secrets.values)).installCRDs
    )

    error_message = "The External Secrets CRDs must be installed."
  }

  assert {
    condition = (
      yamldecode(one(helm_release.external_secrets.values)).replicaCount ==
      var.external_secrets_replicas
    )

    error_message = "External Secrets must use the configured replica count."
  }

  assert {
    condition = (
      yamldecode(one(helm_release.external_secrets.values)).serviceAccount.name ==
      "external-secrets"
    )

    error_message = "External Secrets must use its dedicated service account."
  }

  assert {
    condition = (
      helm_release.cluster_autoscaler.name ==
      "cluster-autoscaler"
    )

    error_message = "The Cluster Autoscaler Helm release name is incorrect."
  }

  assert {
    condition = (
      helm_release.cluster_autoscaler.namespace ==
      "kube-system"
    )

    error_message = "Cluster Autoscaler must run in kube-system."
  }

  assert {
    condition = (
      helm_release.cluster_autoscaler.version ==
      var.cluster_autoscaler_chart_version
    )

    error_message = "The configured Cluster Autoscaler chart version must be used."
  }

  assert {
    condition = (
      yamldecode(one(helm_release.cluster_autoscaler.values)).autoDiscovery.clusterName ==
      "three-tier-eks-dev"
    )

    error_message = "Cluster Autoscaler must discover the development cluster."
  }

  assert {
    condition = (
      yamldecode(one(helm_release.cluster_autoscaler.values)).image.tag ==
      "v1.36.1"
    )

    error_message = "Cluster Autoscaler must use the Kubernetes 1.33-compatible image."
  }

  assert {
    condition = (
      yamldecode(one(helm_release.cluster_autoscaler.values)).rbac.serviceAccount.name ==
      "cluster-autoscaler"
    )

    error_message = "Cluster Autoscaler must use its dedicated service account."
  }

  assert {
    condition     = helm_release.argocd.name == "argocd"
    error_message = "The Argo CD Helm release name is incorrect."
  }

  assert {
    condition     = helm_release.argocd.namespace == "argocd"
    error_message = "Argo CD must use its dedicated namespace."
  }

  assert {
    condition     = helm_release.argocd.chart == "argo-cd"
    error_message = "The official Argo CD chart must be installed."
  }

  assert {
    condition = (
      helm_release.argocd.version ==
      var.argocd_chart_version
    )

    error_message = "The configured Argo CD chart version must be used."
  }

  assert {
    condition = (
      yamldecode(one(helm_release.argocd.values)).crds.install
    )

    error_message = "Argo CD CRDs must be installed."
  }

  assert {
    condition = (
      yamldecode(one(helm_release.argocd.values)).server.service.type ==
      "ClusterIP"
    )

    error_message = "The Argo CD server must remain internal by default."
  }

  assert {
    condition = (
      !yamldecode(one(helm_release.argocd.values)).configs.params["server.insecure"]
    )

    error_message = "The Argo CD server must retain TLS."
  }

  assert {
    condition = (
      yamldecode(one(helm_release.argocd.values)).server.replicas ==
      var.argocd_server_replicas
    )

    error_message = "Argo CD must use the configured server replica count."
  }

  assert {
    condition = (
      yamldecode(one(helm_release.argocd.values)).repoServer.replicas ==
      var.argocd_repo_server_replicas
    )

    error_message = "Argo CD must use the configured repository server replica count."
  }

  assert {
    condition = (
      yamldecode(one(helm_release.argocd.values)).applicationSet.replicas ==
      var.argocd_application_set_replicas
    )

    error_message = "Argo CD must use the configured ApplicationSet replica count."
  }

  assert {
    condition = (
      !yamldecode(one(helm_release.argocd.values)).dex.enabled
    )

    error_message = "Dex must remain disabled until an identity provider is configured."
  }
}

