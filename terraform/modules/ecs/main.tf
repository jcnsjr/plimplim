resource "aws_ecs_cluster" "main" {
  name = "plimplim-cluster"
}

resource "aws_ecs_task_definition" "python_task" {
  family = "app1-python-task"
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn  # Role de execução
  task_role_arn            = aws_iam_role.ecs_execution_role.arn  # Role da task (caso precise de permissões adicionais)
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
          value = "redis.plimplim.local"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/app1-python"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "app1-python"
        }
      }
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
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn  # Role de execução
  task_role_arn            = aws_iam_role.ecs_execution_role.arn  # Role da task (caso precise de permissões adicionais)
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
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/app2-go"
          awslogs-region        = "us-east-1" # Change to your AWS region
          awslogs-stream-prefix = "app2-go"
        }
      }
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
    subnets          = [var.subnet_private_az1_id, var.subnet_private_az2_id]
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_sg.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.python_tg.arn
    container_name   = "app1-python-app"
    container_port   = 5000
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
    subnets          = [var.subnet_private_az1_id, var.subnet_private_az2_id]
    assign_public_ip = true
    security_groups  = [aws_security_group.ecs_sg.id]
  }
  load_balancer {
    target_group_arn = aws_lb_target_group.go_tg.arn
    container_name   = "app2-go-app"
    container_port   = 5000
  }
}

resource "aws_lb" "python_alb" {
  name               = "python-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = [var.subnet_public_az1_id, var.subnet_public_az2_id]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "python_tg" {
  name        = "python-target-group"
  port        = 5000  # Porta da aplicação
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/fixed"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "python_http" {
  load_balancer_arn = aws_lb.python_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.python_tg.arn
  }
}

resource "aws_lb" "go_alb" {
  name               = "go-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [var.alb_sg_id]
  subnets            = [var.subnet_public_az1_id, var.subnet_public_az2_id]

  enable_deletion_protection = false
}

resource "aws_lb_target_group" "go_tg" {
  name        = "go-target-group"
  port        = 5000  # Porta da aplicação
  protocol    = "HTTP"
  vpc_id      = var.vpc_id
  target_type = "ip"

  health_check {
    path                = "/fixed"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "go_http" {
  load_balancer_arn = aws_lb.go_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.go_tg.arn
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


resource "aws_iam_role" "ecs_execution_role" {
  name = "ecs-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action    = "sts:AssumeRole"
        Effect    = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_role_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_cloudwatch_log_group" "app1_python_logs" {
  name = "/ecs/app1-python"
  retention_in_days = 1  # Defina a retenção conforme necessário
} 

resource "aws_cloudwatch_log_group" "app2_go_logs" {
  name = "/ecs/app2-go"
  retention_in_days = 1  # Defina a retenção conforme necessário
} 