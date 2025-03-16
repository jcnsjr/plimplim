variable "ecs_cluster_id" {
  description = "ECS Cluster ID"
  type        = string
}

variable "subnet_az1_id" {
  description = "Subnet 1 ID"
  type        = string
}

variable "subnet_az2_id" {
  description = "Subnet 2 ID"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde o ECS será implantado"
  type        = string
}

variable "local_dns_id" {
  description = "ID da VPC onde o ECS será implantado"
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "ID da VPC onde o ECS será implantado"
  type        = string
}

variable "redis_image" {
  description = "Docker image for the Go application"
  type        = string
}