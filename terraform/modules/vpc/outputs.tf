output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_public_az1_id" {
  value = aws_subnet.subnet_public_az1.id
}

output "subnet_public_az2_id" {
  value = aws_subnet.subnet_public_az2.id
}

output "subnet_private_az1_id" {
  value = aws_subnet.subnet_private_az1.id
}

output "subnet_private_az2_id" {
  value = aws_subnet.subnet_private_az2.id
}

output "local_dns_id" {
  value = aws_service_discovery_private_dns_namespace.local_dns.id
}

output "alb_sg_id" {
  value = aws_security_group.alb_sg.id
}