output "python_alb_dns_name" {
  description = "DNS da aplicação Python"
  value       = module.ecs.python_alb_dns_name
}

output "go_alb_dns_name" {
  description = "DNS da aplicação GO"
  value       = module.ecs.go_alb_dns_name
}
