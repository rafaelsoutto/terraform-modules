resource "aws_ecr_repository" "this" {
  name                 = var.repository_name
  image_tag_mutability = var.image_tag_mutability
  tags                 = var.tags

  lifecycle {
    prevent_destroy = true
  }
}

