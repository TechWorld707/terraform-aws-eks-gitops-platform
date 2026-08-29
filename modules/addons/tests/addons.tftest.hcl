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

run "core_eks_addons" {
  command = plan

  variables {
    name         = "three-tier-eks"
    environment  = "dev"
    cluster_name = "three-tier-eks-dev"
    external_dns_hosted_zone_ids = [
      "Z0123456789ABCDEF"
    ]
    external_secrets_secret_arns = [
      "arn:aws:secretsmanager:us-east-1:123456789012:secret:three-tier-eks/dev/database-AbCdEf"
    ]

    external_secrets_kms_key_arns = [
      "arn:aws:kms:us-east-1:123456789012:key/1234abcd-12ab-34cd-56ef-1234567890ab"
    ]

    tags = {
      Owner = "platform-engineering"
    }
  }

  assert {
    condition = (
      aws_eks_addon.pod_identity_agent.addon_name ==
      "eks-pod-identity-agent"
    )

    error_message = "The EKS Pod Identity Agent must be installed."
  }

  assert {
    condition     = length(aws_eks_addon.managed) == 5
    error_message = "The module must install five managed add-ons."
  }

  assert {
    condition = (
      aws_eks_addon.managed["coredns"].addon_name ==
      "coredns"
    )

    error_message = "The CoreDNS add-on must be installed."
  }

  assert {
    condition = (
      aws_eks_addon.managed["kube_proxy"].addon_name ==
      "kube-proxy"
    )

    error_message = "The kube-proxy add-on must be installed."
  }

  assert {
    condition = (
      aws_eks_addon.managed["vpc_cni"].addon_name ==
      "vpc-cni"
    )

    error_message = "The VPC CNI add-on must be installed."
  }

  assert {
    condition = (
      aws_eks_addon.managed["ebs_csi"].addon_name ==
      "aws-ebs-csi-driver"
    )

    error_message = "The EBS CSI driver add-on must be installed."
  }

  assert {
    condition = (
      aws_iam_role.pod_identity["vpc_cni"].name ==
      "three-tier-eks-dev-vpc-cni"
    )

    error_message = "The VPC CNI Pod Identity role name is incorrect."
  }

  assert {
    condition = (
      aws_iam_role.pod_identity["ebs_csi"].name ==
      "three-tier-eks-dev-ebs-csi"
    )

    error_message = "The EBS CSI Pod Identity role name is incorrect."
  }

  assert {
    condition = (
      aws_iam_role_policy_attachment.pod_identity["vpc_cni"].policy_arn ==
      "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
    )

    error_message = "The VPC CNI role must use AmazonEKS_CNI_Policy."
  }

  assert {
    condition = (
      aws_iam_role_policy_attachment.pod_identity["ebs_csi"].policy_arn ==
      "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicyV2"
    )

    error_message = "The EBS CSI role must use AmazonEBSCSIDriverPolicyV2."
  }

  assert {
    condition = (
      aws_eks_pod_identity_association.this["vpc_cni"].namespace ==
      "kube-system" &&
      aws_eks_pod_identity_association.this["vpc_cni"].service_account ==
      "aws-node"
    )

    error_message = "The VPC CNI Pod Identity association is incorrect."
  }

  assert {
    condition = (
      aws_eks_pod_identity_association.this["ebs_csi"].namespace ==
      "kube-system" &&
      aws_eks_pod_identity_association.this["ebs_csi"].service_account ==
      "ebs-csi-controller-sa"
    )

    error_message = "The EBS CSI Pod Identity association is incorrect."
  }

  assert {
    condition = alltrue([
      for addon in aws_eks_addon.managed :
      addon.resolve_conflicts_on_create == "OVERWRITE"
    ])

    error_message = "Managed add-ons must overwrite conflicts during creation."
  }

  assert {
    condition = alltrue([
      for addon in aws_eks_addon.managed :
      addon.resolve_conflicts_on_update == "PRESERVE"
    ])

    error_message = "Managed add-ons must preserve custom fields during updates."
  }

  assert {
    condition = (
      aws_eks_addon.pod_identity_agent.tags["Module"] == "addons" &&
      aws_eks_addon.pod_identity_agent.tags["Owner"] == "platform-engineering"
    )

    error_message = "Required tags must be applied to the add-ons."
  }

  assert {
    condition = (
      aws_iam_role.load_balancer_controller.name ==
      "three-tier-eks-dev-load-balancer-controller"
    )

    error_message = "The AWS Load Balancer Controller Pod Identity role name is incorrect."
  }

  assert {
    condition = (
      aws_iam_policy.load_balancer_controller.name ==
      "three-tier-eks-dev-load-balancer-controller"
    )

    error_message = "The AWS Load Balancer Controller IAM policy name is incorrect."
  }

  assert {
    condition = (
      aws_eks_pod_identity_association.load_balancer_controller.namespace ==
      "kube-system" &&
      aws_eks_pod_identity_association.load_balancer_controller.service_account ==
      "aws-load-balancer-controller"
    )

    error_message = "The AWS Load Balancer Controller Pod Identity association is incorrect."
  }

  assert {
    condition = (
      jsondecode(
        file(
          "${path.module}/policies/aws-load-balancer-controller-v2.14.1.json"
        )
      ).Version ==
      "2012-10-17"
    )

    error_message = "The vendored AWS Load Balancer Controller policy must use the expected IAM policy version."
  }

  assert {
    condition = (
      length(
        jsondecode(
          file(
            "${path.module}/policies/aws-load-balancer-controller-v2.14.1.json"
          )
        ).Statement
      ) > 0
    )

    error_message = "The vendored AWS Load Balancer Controller policy must contain permission statements."
  }

  assert {
    condition = (
      aws_iam_role.external_dns.name ==
      "three-tier-eks-dev-external-dns"
    )

    error_message = "The ExternalDNS Pod Identity role name is incorrect."
  }

  assert {
    condition = (
      aws_eks_pod_identity_association.external_dns.namespace ==
      "external-dns"
    )

    error_message = "ExternalDNS must use the external-dns namespace."
  }

  assert {
    condition = (
      aws_eks_pod_identity_association.external_dns.service_account ==
      "external-dns"
    )

    error_message = "The ExternalDNS Pod Identity service account is incorrect."
  }

  assert {
    condition = (
      aws_iam_role.external_secrets.name ==
      "three-tier-eks-dev-external-secrets"
    )

    error_message = "The External Secrets Pod Identity role name is incorrect."
  }

  assert {
    condition = (
      aws_eks_pod_identity_association.external_secrets.namespace ==
      "external-secrets"
    )

    error_message = "External Secrets must use the external-secrets namespace."
  }

  assert {
    condition = (
      aws_eks_pod_identity_association.external_secrets.service_account ==
      "external-secrets"
    )

    error_message = "The External Secrets Pod Identity service account is incorrect."
  }

  assert {
    condition = (
      aws_iam_role.external_secrets.permissions_boundary == null
    )

    error_message = "External Secrets must not use a permissions boundary by default."
  }

  assert {
    condition = (
      aws_iam_role.external_secrets.tags["Controller"] ==
      "external-secrets"
    )

    error_message = "The External Secrets role must include its controller tag."
  }
}