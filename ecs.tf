resource "aws_ecs_cluster" "blog" {
  name = "blog"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }

  tags = {
    Name = "blog-${local.name_suffix}"
  }
}

resource "aws_ecs_task_definition" "blog_backend" {
  family = "blog-backend"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_blog.arn
  task_role_arn            = aws_iam_role.ecs_task_blog.arn

  container_definitions = jsonencode([
    {
      name  = "blog-backend"
      image = "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/${aws_ecr_repository.blog_backend.name}:latest"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])

  tags = {
    Name = "blog-backend-${local.name_suffix}"
  }
}

resource "aws_ecs_task_definition" "blog_frontend" {
  family = "blog-frontend"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512
  execution_role_arn       = aws_iam_role.ecs_task_execution_blog.arn
  task_role_arn            = aws_iam_role.ecs_task_blog.arn

  container_definitions = jsonencode([
    {
      name  = "blog-frontend"
      image = "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/${aws_ecr_repository.blog_frontend.name}:latest"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])

  tags = {
    Name = "blog-frontend-${local.name_suffix}"
  }
}