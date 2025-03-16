variable "python_app_image" {
  description = "Docker image for the Python application"
  type        = string
}

variable "go_app_image" {
  description = "Docker image for the Go application"
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
