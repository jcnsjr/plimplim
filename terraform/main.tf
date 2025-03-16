provider "aws" {
  region = "us-east-1"
}

module "vpc" {
  source              = "./modules/vpc"
  vpc_cidr            = "10.0.0.0/16"
  subnet_az1_cidr     = "10.0.10.0/24"
  subnet_az2_cidr     = "10.0.20.0/24"
  availability_zone_1 = "us-east-1a"
  availability_zone_2 = "us-east-1b"
}

module "ecs" {
  source               = "./modules/ecs"
  python_app_image     = "jcnsjr/app1-python:latest"
  go_app_image         = "jcnsjr/app2-go:latest"
  subnet_az1_id        = module.vpc.subnet_az1_id
  subnet_az2_id        = module.vpc.subnet_az2_id
  vpc_id               = module.vpc.vpc_id
  redis_service_id     = module.redis.redis_service_id
}

module "redis" {
  source               = "./modules/redis"
  ecs_cluster_id       = module.ecs.ecs_cluster_id
  subnet_az1_id        = module.vpc.subnet_az1_id
  subnet_az2_id        = module.vpc.subnet_az2_id
  vpc_id               = module.vpc.vpc_id
  local_dns_id         = module.vpc.local_dns_id
}