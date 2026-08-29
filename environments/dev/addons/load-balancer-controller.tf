resource "helm_release" "aws_load_balancer_controller" {
  name       = "aws-load-balancer-controller"
  namespace  = "kube-system"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  version    = var.load_balancer_controller_chart_version

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 600

  values = [
    yamlencode({
      clusterName  = data.terraform_remote_state.foundation.outputs.eks_cluster_name
      region       = var.aws_region
      vpcId        = data.terraform_remote_state.foundation.outputs.vpc_id
      replicaCount = var.load_balancer_controller_replicas

      serviceAccount = {
        create = true
        name   = "aws-load-balancer-controller"
      }
    })
  ]

  depends_on = [
    module.addons
  ]
}
