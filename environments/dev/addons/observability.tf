locals {
  observability_namespace = "monitoring"
  observability_cluster   = data.terraform_remote_state.foundation.outputs.eks_cluster_name
  observability_storage   = "observability-gp3"

  observability_charts = {
    monitoring = {
      repository = "https://prometheus-community.github.io/helm-charts"
      chart      = "kube-prometheus-stack"
      version    = "93.4.1"
      values = yamlencode({
        kubeEtcd              = { enabled = false }
        kubeScheduler         = { enabled = false }
        kubeControllerManager = { enabled = false }
        kubeProxy             = { enabled = false }
        defaultRules = {
          rules = {
            etcd                   = false
            kubeSchedulerAlerting  = false
            kubeSchedulerRecording = false
            kubeControllerManager  = false
            kubeProxy              = false
          }
        }
        prometheus = {
          prometheusSpec = {
            retention     = "7d"
            retentionSize = "8GB"
            storageSpec = {
              volumeClaimTemplate = {
                spec = {
                  storageClassName = local.observability_storage
                  accessModes      = ["ReadWriteOnce"]
                  resources        = { requests = { storage = "10Gi" } }
                }
              }
            }
          }
        }
        alertmanager = {
          alertmanagerSpec = {
            useExistingSecret = var.observability_alertmanager_config_secret != null
            configSecret      = var.observability_alertmanager_config_secret
          }
        }
        grafana = {
          serviceAccount = { create = true, name = "observability-grafana" }
          additionalDataSources = [
            {
              name   = "CloudWatch"
              uid    = "cloudwatch"
              type   = "cloudwatch"
              access = "proxy"
              jsonData = {
                authType      = "default"
                defaultRegion = var.aws_region
              }
            },
            {
              name   = "Tempo"
              uid    = "tempo"
              type   = "tempo"
              access = "proxy"
              url    = "http://tempo:3200"
            }
          ]
        }
      })
    }
    tempo = {
      repository = "https://grafana-community.github.io/helm-charts"
      chart      = "tempo"
      version    = "3.2.1"
      values = yamlencode({
        fullnameOverride = "tempo"
        persistence = {
          enabled          = true
          storageClassName = local.observability_storage
          size             = "10Gi"
        }
        tempo = { retention = "48h" }
      })
    }
    otel-collector = {
      repository = "https://open-telemetry.github.io/opentelemetry-helm-charts"
      chart      = "opentelemetry-collector"
      version    = "0.179.1"
      values = yamlencode({
        fullnameOverride = "otel-collector"
        mode             = "deployment"
        image            = { repository = "otel/opentelemetry-collector" }
        command          = { name = "otelcol" }
        ports = {
          for name in ["otlp", "otlp-http", "jaeger-compact", "jaeger-thrift", "jaeger-grpc", "zipkin"] :
          name => { enabled = name == "otlp-http" }
        }
        resources = {
          requests = { cpu = "50m", memory = "128Mi" }
          limits   = { memory = "256Mi" }
        }
        alternateConfig = {
          extensions = {
            health_check = { endpoint = "$${env:MY_POD_IP}:13133" }
          }
          receivers = {
            otlp = { protocols = { http = { endpoint = "$${env:MY_POD_IP}:4318" } } }
          }
          processors = {
            memory_limiter = { check_interval = "1s", limit_mib = 200, spike_limit_mib = 40 }
            batch          = {}
          }
          exporters = {
            otlp_grpc = {
              endpoint = "tempo.monitoring.svc.cluster.local:4317"
              tls      = { insecure = true }
            }
          }
          service = {
            extensions = ["health_check"]
            pipelines = {
              traces = {
                receivers  = ["otlp"]
                processors = ["memory_limiter", "batch"]
                exporters  = ["otlp_grpc"]
              }
            }
          }
        }
      })
    }
    blackbox = {
      repository = "https://prometheus-community.github.io/helm-charts"
      chart      = "prometheus-blackbox-exporter"
      version    = "11.21.3"
      values = yamlencode({
        fullnameOverride = "blackbox"
        config = {
          modules = {
            http_2xx = {
              prober  = "http"
              timeout = "5s"
              http    = { preferred_ip_protocol = "ip4" }
            }
          }
        }
      })
    }
    fluent-bit = {
      repository = "https://fluent.github.io/helm-charts"
      chart      = "fluent-bit"
      version    = "0.58.3"
      values = yamlencode({
        serviceAccount = { name = "observability-fluent-bit" }
        config = {
          inputs  = <<-CONFIG
            [INPUT]
                Name              tail
                Path              /var/log/containers/*_three-tier-dev_*.log
                Tag               kube.*
                multiline.parser  docker, cri
                DB                /var/fluent-bit/state/tail.db
                Mem_Buf_Limit     20MB
                Skip_Long_Lines   On
          CONFIG
          filters = <<-CONFIG
            [FILTER]
                Name              kubernetes
                Match             kube.*
                Merge_Log         On
                Keep_Log          Off
                Labels            Off
                Annotations       Off
          CONFIG
          outputs = <<-CONFIG
            [OUTPUT]
                Name              cloudwatch_logs
                Match             kube.*
                region            ${var.aws_region}
                log_group_name    ${aws_cloudwatch_log_group.workloads.name}
                log_stream_prefix pod-
                auto_create_group false
          CONFIG
        }
        extraVolumes = [{
          name     = "tail-state"
          hostPath = { path = "/var/lib/three-tier-fluent-bit", type = "DirectoryOrCreate" }
        }]
        extraVolumeMounts = [{
          name      = "tail-state"
          mountPath = "/var/fluent-bit/state"
        }]
      })
    }
  }
}

resource "kubernetes_storage_class_v1" "observability" {
  metadata {
    name = local.observability_storage
  }

  storage_provisioner    = "ebs.csi.aws.com"
  volume_binding_mode    = "WaitForFirstConsumer"
  reclaim_policy         = "Delete"
  allow_volume_expansion = true

  parameters = {
    type      = "gp3"
    encrypted = "true"
  }

  depends_on = [module.addons]
}

resource "helm_release" "observability" {
  for_each = local.observability_charts

  name             = each.key
  namespace        = local.observability_namespace
  create_namespace = false
  repository       = each.value.repository
  chart            = each.value.chart
  version          = each.value.version
  values           = [each.value.values]

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 900

  depends_on = [
    kubernetes_namespace_v1.observability,
    kubernetes_storage_class_v1.observability,
    aws_eks_pod_identity_association.observability
  ]
}

resource "kubernetes_namespace_v1" "observability" {
  metadata {
    name = local.observability_namespace
  }
}

variable "observability_alertmanager_config_secret" {
  description = "Existing Secret in monitoring containing alertmanager.yaml, used for notification routing."
  type        = string
  default     = null
}
