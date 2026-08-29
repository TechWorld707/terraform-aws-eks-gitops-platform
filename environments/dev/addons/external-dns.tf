resource "helm_release" "external_dns" {
  name             = "external-dns"
  namespace        = "external-dns"
  create_namespace = true

  repository = "https://kubernetes-sigs.github.io/external-dns/"
  chart      = "external-dns"
  version    = var.external_dns_chart_version

  atomic          = true
  cleanup_on_fail = true
  wait            = true
  timeout         = 600

  values = [
    yamlencode({
      provider = {
        name = "aws"
      }

      policy        = var.external_dns_policy
      registry      = "txt"
      txtOwnerId    = var.external_dns_txt_owner_id
      domainFilters = sort(tolist(var.external_dns_domain_filters))
      sources       = ["ingress", "service"]

      serviceAccount = {
        create = true
        name   = "external-dns"
      }
    })
  ]

  depends_on = [
    module.addons
  ]
}