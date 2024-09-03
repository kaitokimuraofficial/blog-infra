resource "aws_ecs_cluster" "nginx" {
  name = "nginx"

  tags = {
    Name = "nginx-${local.name_suffix}"
  }
}

resource "aws_ecs_task_definition" "nginx" {
  family = "nginx"

  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]

  runtime_platform {
    operating_system_family = "LINUX"
    cpu_architecture        = "ARM64"
  }

  cpu                = 512
  memory             = 1024
  execution_role_arn = aws_iam_role.ecs_task_execution_blog.arn
  task_role_arn      = aws_iam_role.ecs_task_blog.arn

  container_definitions = jsonencode([
    {
      name  = "nginx"
      image = "${data.aws_caller_identity.self.account_id}.dkr.ecr.ap-northeast-1.amazonaws.com/${aws_ecr_repository.nginx.name}:latest"
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
        }
      ]
    }
  ])

  tags = {
    Name = "nginx-${local.name_suffix}"
  }
}

resource "aws_ecs_service" "nginx" {
  name = "nginx"

  cluster       = aws_ecs_cluster.nginx.name
  launch_type   = "FARGATE"
  desired_count = "1"

  task_definition = aws_ecs_task_definition.nginx.arn

  network_configuration {
    subnets = [
      aws_subnet.subnets["public-1a"].id,
      aws_subnet.subnets["public-1c"].id
    ]
    security_groups = [aws_security_group.alb_web.id]
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.nginx.arn
    container_name   = "nginx"
    container_port   = "80"
  }
}