provider "aws" {
  region = var.aws_region

  default_tags {
    tags = merge(
      {
        Project   = var.project_name
        ManagedBy = "Terraform"
        Component = "bootstrap"
      },
      var.tags
    )
  }
}
