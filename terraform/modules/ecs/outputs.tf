output "ecs_cluster_id" {
  value = aws_ecs_cluster.main.id
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}

output "python_alb_dns_name" {
  description = "DNS do Load Balancer"
  value       = aws_lb.python_alb.dns_name
}

output "go_alb_dns_name" {
  description = "DNS do Load Balancer"
  value       = aws_lb.go_alb.dns_name
}

output "ecs_sg_id" {
  value = aws_security_group.ecs_sg.id
}