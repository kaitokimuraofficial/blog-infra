resource "aws_ecr_repository" "blog_backend" {
  name                 = "blog-backend"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "blog_backend" {
  repository = aws_ecr_repository.blog_backend.name

  policy = jsonencode(
    {
      "rules" : [
        {
          "rulePriority" : 1,
          "description" : "Keep last 10 images",
          "selection" : {
            "tagStatus" : "tagged",
            "tagPrefixList" : ["dev"],
            "countType" : "imageCountMoreThan",
            "countNumber" : 10
          },
          "action" : {
            "type" : "expire"
          }
        },
        {
          "rulePriority" : 2,
          "description" : "Keep last 5 images",
          "selection" : {
            "tagStatus" : "tagged",
            "tagPrefixList" : ["prod"],
            "countType" : "imageCountMoreThan",
            "countNumber" : 5
          },
          "action" : {
            "type" : "expire"
          }
        }
      ]
    }
  )
}

resource "aws_ecr_repository" "blog_frontend" {
  name                 = "blog-frontend"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_lifecycle_policy" "blog_frontend" {
  repository = aws_ecr_repository.blog_frontend.name

  policy = jsonencode(
    {
      "rules" : [
        {
          "rulePriority" : 1,
          "description" : "Keep last 10 images",
          "selection" : {
            "tagStatus" : "tagged",
            "tagPrefixList" : ["dev"],
            "countType" : "imageCountMoreThan",
            "countNumber" : 10
          },
          "action" : {
            "type" : "expire"
          }
        },
        {
          "rulePriority" : 2,
          "description" : "Keep last 5 images",
          "selection" : {
            "tagStatus" : "tagged",
            "tagPrefixList" : ["prod"],
            "countType" : "imageCountMoreThan",
            "countNumber" : 5
          },
          "action" : {
            "type" : "expire"
          }
        }
      ]
    }
  )
}