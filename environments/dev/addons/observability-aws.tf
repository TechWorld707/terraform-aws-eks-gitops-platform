data "aws_partition" "observability" {}

resource "aws_cloudwatch_log_group" "workloads" {
  name              = "/aws/eks/${local.observability_cluster}/three-tier-dev"
  retention_in_days = 14
}

locals {
  observability_aws_policies = {
    grafana = [
      {
        Effect   = "Allow"
        Action   = ["cloudwatch:DescribeAlarms", "cloudwatch:ListMetrics", "cloudwatch:GetMetricData", "ec2:DescribeRegions", "tag:GetResources", "logs:DescribeLogGroups"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = ["logs:StartQuery", "logs:GetLogGroupFields", "logs:GetLogEvents"]
        Resource = [
          "${aws_cloudwatch_log_group.workloads.arn}:*",
          "arn:${data.aws_partition.observability.partition}:logs:${var.aws_region}:*:log-group:/aws/eks/${local.observability_cluster}/cluster:*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = ["logs:GetQueryResults", "logs:StopQuery"]
        Resource = "*"
      }
    ]
    fluent-bit = [
      {
        Effect   = "Allow"
        Action   = ["logs:CreateLogStream", "logs:PutLogEvents", "logs:DescribeLogStreams"]
        Resource = ["${aws_cloudwatch_log_group.workloads.arn}:*"]
      }
    ]
  }
}

resource "aws_iam_role" "observability" {
  for_each = local.observability_aws_policies

  name = "${local.observability_cluster}-${each.key}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "pods.eks.amazonaws.com" }
      Action    = ["sts:AssumeRole", "sts:TagSession"]
      Condition = {
        StringEquals = {
          "aws:RequestTag/eks-cluster-name"           = local.observability_cluster
          "aws:RequestTag/kubernetes-namespace"       = local.observability_namespace
          "aws:RequestTag/kubernetes-service-account" = "observability-${each.key}"
        }
      }
    }]
  })
}

resource "aws_iam_role_policy" "observability" {
  for_each = local.observability_aws_policies

  name = "cloudwatch"
  role = aws_iam_role.observability[each.key].id
  policy = jsonencode({
    Version   = "2012-10-17"
    Statement = each.value
  })
}

resource "aws_eks_pod_identity_association" "observability" {
  for_each = local.observability_aws_policies

  cluster_name    = local.observability_cluster
  namespace       = local.observability_namespace
  service_account = "observability-${each.key}"
  role_arn        = aws_iam_role.observability[each.key].arn

  depends_on = [module.addons, aws_iam_role_policy.observability]
}

variable "observability_alb" {
  description = "Optional ARN suffixes for the app ALB and frontend target group, with an optional existing SNS notification topic ARN."
  type = object({
    load_balancer = string
    target_group  = string
    sns_topic_arn = optional(string)
  })
  default = null
}

resource "aws_cloudwatch_metric_alarm" "observability_alb" {
  count = var.observability_alb == null ? 0 : 1

  alarm_name          = "${local.observability_cluster}-unhealthy-targets"
  namespace           = "AWS/ApplicationELB"
  metric_name         = "UnHealthyHostCount"
  statistic           = "Maximum"
  threshold           = 1
  comparison_operator = "GreaterThanOrEqualToThreshold"
  period              = 60
  evaluation_periods  = 3
  datapoints_to_alarm = 3
  treat_missing_data  = "notBreaching"
  alarm_actions       = var.observability_alb.sns_topic_arn == null ? [] : [var.observability_alb.sns_topic_arn]

  dimensions = {
    LoadBalancer = var.observability_alb.load_balancer
    TargetGroup  = var.observability_alb.target_group
  }
}
