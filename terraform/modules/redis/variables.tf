variable "ecs_cluster_id" {
  description = "ECS Cluster ID"
  type        = string
}

variable "subnet_private_az1_id" {
  description = "Subnet 1 ID"
  type        = string
}

variable "subnet_private_az2_id" {
  description = "Subnet 2 ID"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde o ECS será implantado"
  type        = string
}

variable "local_dns_id" {
  description = "ID do DNS plimplim.local"
  type        = string
}

variable "ecs_execution_role_arn" {
  description = "ARN da execution role"
  type        = string
}

variable "redis_image" {
  description = "Docker image for Redis"
  type        = string
}

variable "ecs_sg_id" {
  description = "Docker image for Redis"
  type        = string
}
