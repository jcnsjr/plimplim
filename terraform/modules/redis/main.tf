resource "aws_ecs_task_definition" "redis" {
  family = "redis-task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 256
  memory                   = 512
  container_definitions = jsonencode([
    {
      name      = "redis"
      image     = "redis:alpine"
      cpu       = 256
      memory    = 512
      essential = true
      healthCheck = {
        command = ["CMD", "redis-cli", "ping"]  # Verifica se o Redis está respondendo
        interval = 30  # Intervalo de 30 segundos
        retries  = 3   # Tenta 3 vezes
        start_period = 30  # Espera 30 segundos para começar a verificar
        timeout  = 5   # Tempo de timeout para cada tentativa
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
    subnets          = [var.subnet_az1_id, var.subnet_az2_id]
    assign_public_ip = true
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