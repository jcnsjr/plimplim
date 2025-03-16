resource "aws_ecs_cluster" "main" {
  name = "plimplim-cluster"
}

resource "aws_ecs_task_definition" "python_task" {
  family = "app1-python-task"
  # execution_role_arn       = aws_iam_role.ecs_execution_role.arn  # Role de execução
  # task_role_arn            = aws_iam_role.ecs_execution_role.arn  # Role da task (caso precise de permissões adicionais)
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions = jsonencode([
    {
      name      = "app1-python-app"
      image     = var.python_app_image
      cpu       = 256
      memory    = 512
      essential = true
      environment = [
        {
          name  = "CACHE_REDIS_HOST"
          value = "redis.plimplim.local"  # Nome do serviço no Service Discovery
        }
      ]
      # log_configuration = {
      #   logDriver = "awslogs"
      #   options = {
      #     "awslogs-group"         = "/ecs/my-app-logs"
      #     "awslogs-region"        = "us-east-1"
      #     "awslogs-stream-prefix" = "python-app"
      #   }
      # }
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
    }
  ])
}

resource "aws_ecs_task_definition" "go_task" {
  family = "app2-go-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions = jsonencode([
    {
      name      = "app2-go-app"
      image     = var.go_app_image
      cpu       = 256
      memory    = 512
      essential = true
      environment = [
        {
          name  = "CACHE_REDIS_HOST"
          value = "redis.plimplim.local"  # Nome do serviço no Service Discovery
        }
      ]
      portMappings = [
        {
          containerPort = 5000
          hostPort      = 5000
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "python_service" {
  name            = "app1-python-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.python_task.arn
  depends_on = [var.redis_service_id]
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [var.subnet_az1_id, var.subnet_az2_id]
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_sg.id]
  }
}

resource "aws_ecs_service" "go_service" {
  name            = "app2-go-service"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.go_task.arn
  depends_on = [var.redis_service_id]
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [var.subnet_az1_id, var.subnet_az2_id]
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_sg.id]
  }
}

resource "aws_security_group" "ecs_sg" {
  name   = "ecs-security-group"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 5000
    to_port     = 5000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"] 
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


# resource "aws_iam_role" "ecs_execution_role" {
#   name = "ecs-execution-role"

#   assume_role_policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Action    = "sts:AssumeRole"
#         Effect    = "Allow"
#         Principal = {
#           Service = "ecs-tasks.amazonaws.com"
#         }
#       }
#     ]
#   })
# }

# resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
#   role       = aws_iam_role.ecs_execution_role.name
#   policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
# }


# resource "aws_cloudwatch_log_group" "ecs_logs" {
#   name = "/ecs/my-app-logs"
#   retention_in_days = 30  # Defina a retenção conforme necessário
# } 