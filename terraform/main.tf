provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source           = "./modules/vpc"
  vpc_cidr         = "10.0.0.0/16"
  subnet_az1_cidr    = "10.0.10.0/24"
  subnet_az2_cidr    = "10.0.20.0/24"
  availability_zone_1 = "us-east-1a"
  availability_zone_2 = "us-east-1b"
}