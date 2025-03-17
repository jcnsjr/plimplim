resource "aws_ecs_task_definition" "redis" {
  family = "redis-task"
  execution_role_arn       = var.ecs_execution_role_arn  # Role de execução
  task_role_arn            = var.ecs_execution_role_arn  # Role da task (caso precise de permissões adicionais)
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions = jsonencode([
    {
      name      = "redis"
      image     = var.redis_image
      cpu       = 256
      memory    = 512
      essential = true
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/redis"
          awslogs-region        = "us-east-1"
          awslogs-stream-prefix = "redis"
        }
      }
      portMappings = [
        {
          containerPort = 6379
          hostPort      = 6379
        }
      ]
    }
  ])
}

resource "aws_ecs_service" "redis_service" {
  name            = "redis-service"
  cluster         = var.ecs_cluster_id
  task_definition = aws_ecs_task_definition.redis.arn
  desired_count   = 1
  launch_type     = "FARGATE"
  network_configuration {
    subnets          = [var.subnet_private_az1_id, var.subnet_private_az2_id]
    security_groups  = [aws_security_group.redis_sg.id]
  }
  service_registries {
    registry_arn = aws_service_discovery_service.redis_service_discovery.arn
  }
}

resource "aws_security_group" "redis_sg" {
  name   = "redis-security-group"
  vpc_id = var.vpc_id

  ingress {
    from_port   = 6379
    to_port     = 6379
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

resource "aws_service_discovery_service" "redis_service_discovery" {
  name = "redis"
  dns_config {
    namespace_id = var.local_dns_id
    dns_records {
      ttl  = 10
      type = "A"
    }
    routing_policy = "MULTIVALUE"
  }
}

resource "aws_cloudwatch_log_group" "redis_logs" {
  name = "/ecs/redis"
  retention_in_days = 1  # Defina a retenção conforme necessário
} 