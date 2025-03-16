output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_az1_id" {
  value = aws_subnet.subnet_az1.id
}

output "subnet_az2_id" {
  value = aws_subnet.subnet_az2.id
}

output "local_dns_id" {
  value = aws_service_discovery_private_dns_namespace.local_dns.id
}