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

    foundation_state_kms_key_arn = (
      "arn:aws:kms:us-east-1:123456789012:key/1234abcd-12ab-34cd-56ef-1234567890ab"
    )
  }

  override_data {
    target = data.terraform_remote_state.foundation

    values = {
      outputs = {
        eks_cluster_name = "three-tier-eks-dev"
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
    condition     = length(module.addons.addon_names) == 5
    error_message = "The development add-ons state must install five core add-ons."
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
}