data "aws_iam_policy_document" "flow_logs_kms" {
  #checkov:skip=CKV_AWS_109:KMS administration is restricted to the current AWS account root principal.
  #checkov:skip=CKV_AWS_111:KMS write permissions are restricted to the current account and regional CloudWatch Logs service.
  #checkov:skip=CKV_AWS_356:In a KMS key policy, Resource "*" represents only the key to which the policy is attached.

  statement {
    sid    = "EnableAccountAdministration"
    effect = "Allow"

    principals {
      type = "AWS"

      identifiers = [
        "arn:${data.aws_partition.current.partition}:iam::${data.aws_caller_identity.current.account_id}:root"
      ]
    }

    actions   = ["kms:*"]
    resources = ["*"]
  }

  statement {
    sid    = "AllowCloudWatchLogsEncryption"
    effect = "Allow"

    principals {
      type = "Service"

      identifiers = [
        "logs.${data.aws_region.current.region}.${data.aws_partition.current.dns_suffix}"
      ]
    }

    actions = [
      "kms:Decrypt",
      "kms:DescribeKey",
      "kms:Encrypt",
      "kms:GenerateDataKey*",
      "kms:ReEncrypt*"
    ]

    resources = ["*"]

    condition {
      test     = "ArnLike"
      variable = "kms:EncryptionContext:aws:logs:arn"

      values = [
        "arn:${data.aws_partition.current.partition}:logs:${data.aws_region.current.region}:${data.aws_caller_identity.current.account_id}:log-group:/aws/vpc-flow-log/${local.resource_name}"
      ]
    }
  }
}

resource "aws_kms_key" "flow_logs" {
  description = "Encrypts VPC Flow Logs for ${local.resource_name}"

  deletion_window_in_days = 30
  enable_key_rotation     = true
  policy                  = data.aws_iam_policy_document.flow_logs_kms.json

  lifecycle {
    prevent_destroy = true
  }

  tags = merge(
    local.common_tags,
    {
      Name = "${local.resource_name}-flow-logs"
    }
  )
}

resource "aws_kms_alias" "flow_logs" {
  name          = "alias/${local.resource_name}-flow-logs"
  target_key_id = aws_kms_key.flow_logs.key_id
}

resource "aws_cloudwatch_log_group" "vpc_flow_logs" {
  name = "/aws/vpc-flow-log/${local.resource_name}"

  kms_key_id        = aws_kms_key.flow_logs.arn
  retention_in_days = var.flow_log_retention_days

  tags = merge(
    local.common_tags,
    {
      Name = "${local.resource_name}-flow-logs"
    }
  )
}

data "aws_iam_policy_document" "flow_logs_assume_role" {
  statement {
    sid    = "AllowVPCFlowLogsService"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["vpc-flow-logs.amazonaws.com"]
    }

    actions = [
      "sts:AssumeRole"
    ]
  }
}

resource "aws_iam_role" "flow_logs" {
  name = "${local.resource_name}-vpc-flow-logs"

  assume_role_policy = data.aws_iam_policy_document.flow_logs_assume_role.json

  tags = merge(
    local.common_tags,
    {
      Name = "${local.resource_name}-vpc-flow-logs"
    }
  )
}

data "aws_iam_policy_document" "flow_logs_delivery" {
  statement {
    sid    = "WriteVPCFlowLogs"
    effect = "Allow"

    actions = [
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents"
    ]

    resources = [
      "${aws_cloudwatch_log_group.vpc_flow_logs.arn}:*"
    ]
  }
}

resource "aws_iam_role_policy" "flow_logs" {
  name = "${local.resource_name}-vpc-flow-logs"

  role   = aws_iam_role.flow_logs.id
  policy = data.aws_iam_policy_document.flow_logs_delivery.json
}

resource "aws_flow_log" "this" {
  vpc_id = aws_vpc.this.id

  iam_role_arn    = aws_iam_role.flow_logs.arn
  log_destination = aws_cloudwatch_log_group.vpc_flow_logs.arn
  traffic_type    = "ALL"

  max_aggregation_interval = 60

  log_format = join(
    " ",
    [
      "$${version}",
      "$${account-id}",
      "$${interface-id}",
      "$${srcaddr}",
      "$${dstaddr}",
      "$${srcport}",
      "$${dstport}",
      "$${protocol}",
      "$${packets}",
      "$${bytes}",
      "$${start}",
      "$${end}",
      "$${action}",
      "$${log-status}",
      "$${vpc-id}",
      "$${subnet-id}",
      "$${instance-id}",
      "$${tcp-flags}",
      "$${type}",
      "$${pkt-srcaddr}",
      "$${pkt-dstaddr}",
      "$${region}",
      "$${az-id}",
      "$${sublocation-type}",
      "$${sublocation-id}",
      "$${pkt-src-aws-service}",
      "$${pkt-dst-aws-service}",
      "$${flow-direction}",
      "$${traffic-path}"
    ]
  )


  tags = merge(
    local.common_tags,
    {
      Name = "${local.resource_name}-vpc-flow-logs"
    }
  )
}