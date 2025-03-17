variable "python_app_image" {
  description = "Docker image for the Python application"
  type        = string
}

variable "go_app_image" {
  description = "Docker image for the Go application"
  type        = string
}

variable "subnet_private_az1_id" {
  description = "Private Subnet 1 ID"
  type        = string
}

variable "subnet_private_az2_id" {
  description = "Private Subnet 2 ID"
  type        = string
}

variable "subnet_public_az1_id" {
  description = "Public Subnet 1 ID"
  type        = string
}

variable "subnet_public_az2_id" {
  description = "Public Subnet 2 ID"
  type        = string
}

variable "vpc_id" {
  description = "ID da VPC onde o ECS será implantado"
  type        = string
}

variable "redis_service_id" {
  description = "ID do Redis Service"
  type        = string
}

variable "alb_sg_id" {
  description = "ID do SG para ALB"
  type        = string
}

