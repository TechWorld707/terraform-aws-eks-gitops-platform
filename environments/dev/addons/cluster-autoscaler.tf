resource "helm_release" "cluster_autoscaler" {
  name      = "cluster-autoscaler"
  namespace = "kube-system"

  repository = "https://kubernetes.github.io/autoscaler"
  chart      = "cluster-autoscaler"
  version    = var.cluster_autoscaler_chart_version

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 600

  values = [
    yamlencode({
      autoDiscovery = {
        clusterName = data.terraform_remote_state.foundation.outputs.eks_cluster_name
      }

      awsRegion     = var.aws_region
      cloudProvider = "aws"
      replicaCount  = var.cluster_autoscaler_replicas

      image = {
        tag = var.cluster_autoscaler_image_tag
      }

      rbac = {
        serviceAccount = {
          create = true
          name   = "cluster-autoscaler"
        }
      }

      extraArgs = {
        balance-similar-node-groups = true
        expander                    = "least-waste"
      }
    })
  ]

  depends_on = [
    module.addons
  ]
}