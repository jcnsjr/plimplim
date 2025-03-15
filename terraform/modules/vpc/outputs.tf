output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_1_id" {
  value = aws_subnet.subnet_az1.id
}

output "subnet_2_id" {
  value = aws_subnet.subnet_az2.id
}
