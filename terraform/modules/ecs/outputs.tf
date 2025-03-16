output "ecs_cluster_id" {
  value = aws_ecs_cluster.main.id
}

output "ecs_execution_role_arn" {
  value = aws_iam_role.ecs_execution_role.arn
}
