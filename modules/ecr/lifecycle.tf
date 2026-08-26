resource "aws_ecr_lifecycle_policy" "this" {
  for_each = aws_ecr_repository.this

  repository = each.value.name

  policy = jsonencode(
    {
      rules = [
        {
          rulePriority = 1
          description  = "Expire untagged images after the configured retention period."

          selection = {
            tagStatus   = "untagged"
            countType   = "sinceImagePushed"
            countUnit   = "days"
            countNumber = var.untagged_image_retention_days
          }

          action = {
            type = "expire"
          }
        },
        {
          rulePriority = 2
          description  = "Retain only the configured maximum number of images."

          selection = {
            tagStatus   = "any"
            countType   = "imageCountMoreThan"
            countNumber = var.maximum_image_count
          }

          action = {
            type = "expire"
          }
        }
      ]
    }
  )
}
