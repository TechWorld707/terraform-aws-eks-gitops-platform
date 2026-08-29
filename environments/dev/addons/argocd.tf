resource "helm_release" "argocd" {
  name             = "argocd"
  namespace        = "argocd"
  create_namespace = true

  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  version    = var.argocd_chart_version

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 900

  values = [
    yamlencode({
      crds = {
        install = true
        keep    = false
      }

      configs = {
        params = {
          "server.insecure" = false
        }
      }

      controller = {
        replicas = 1

        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }

          limits = {
            cpu    = "500m"
            memory = "1Gi"
          }
        }
      }

      server = {
        replicas = var.argocd_server_replicas

        service = {
          type = "ClusterIP"
        }

        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }

          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
      }

      repoServer = {
        replicas = var.argocd_repo_server_replicas

        resources = {
          requests = {
            cpu    = "100m"
            memory = "256Mi"
          }

          limits = {
            cpu    = "1"
            memory = "1Gi"
          }
        }
      }

      applicationSet = {
        replicas = var.argocd_application_set_replicas

        resources = {
          requests = {
            cpu    = "100m"
            memory = "128Mi"
          }

          limits = {
            cpu    = "500m"
            memory = "512Mi"
          }
        }
      }

      dex = {
        enabled = false
      }

      notifications = {
        enabled = true
      }
    })
  ]

  depends_on = [
    module.addons,
    helm_release.aws_load_balancer_controller,
    helm_release.external_secrets
  ]
}