resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  enable_dns_support = true
  enable_dns_hostnames = true
  tags = {
    Name = "main-vpc"
  }
}

resource "aws_subnet" "subnet_private_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private_az1_cidr
  availability_zone = var.availability_zone_1
  map_public_ip_on_launch = false
  tags = {
    Name = "subnet_private_az1"
  }
}

resource "aws_subnet" "subnet_private_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_private_az2_cidr
  availability_zone = var.availability_zone_2
  map_public_ip_on_launch = false
  tags = {
    Name = "subnet_private_az2"
  }
}

resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "ngw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet_public_az1.id # O NAT Gateway precisa estar em uma subnet pública
  tags = {
    Name = "ngw"
  }
}

resource "aws_subnet" "subnet_public_az1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_public_az1_cidr
  availability_zone = var.availability_zone_1
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet_public_az1"
  }
}

resource "aws_subnet" "subnet_public_az2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.subnet_public_az2_cidr
  availability_zone = var.availability_zone_2
  map_public_ip_on_launch = true
  tags = {
    Name = "subnet_public_az2"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route" "igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route" "nat_route" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.ngw.id # Usa o NAT Gateway em vez do IGW
}

resource "aws_route_table_association" "subnet_public_az1_association" {
  subnet_id      = aws_subnet.subnet_public_az1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "subnet_public_az2_association" {
  subnet_id      = aws_subnet.subnet_public_az2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "subnet_private_az1_association" {
  subnet_id      = aws_subnet.subnet_private_az1.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "subnet_private_az2_association" {
  subnet_id      = aws_subnet.subnet_private_az2.id
  route_table_id = aws_route_table.private.id
}

resource "aws_service_discovery_private_dns_namespace" "local_dns" {
  name        = "plimplim.local" 
  vpc         = aws_vpc.main.id
  description = "Namespace interno para ECS"
}

resource "aws_security_group" "alb_sg" {
  name        = "alb-sg"
  description = "Security Group for ALB"
  vpc_id      = aws_vpc.main.id

  # Permitir tráfego HTTP de qualquer lugar
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Permitir saída livre (para comunicação com as ECS tasks)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "alb-security-group"
  }
}
