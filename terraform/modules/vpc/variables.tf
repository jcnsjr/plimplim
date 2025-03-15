variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
}

variable "subnet_az1_cidr" {
  description = "CIDR block for Subnet 1"
  type        = string
}

variable "subnet_az2_cidr" {
  description = "CIDR block for Subnet 2"
  type        = string
}

variable "availability_zone_1" {
  description = "Availability Zone 1"
  type        = string
}

variable "availability_zone_2" {
  description = "Availability Zone 2"
  type        = string
}
