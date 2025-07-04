provider "aws" {
  region = var.region
}

# 1. VPC
resource "aws_vpc" "grafana_vpc" {
  cidr_block = "10.0.0.0/16"
  tags = {
    Name = "Grafana-VPC"
  }
}

# 2. Subnet
resource "aws_subnet" "grafana_subnet" {
  vpc_id                  = aws_vpc.grafana_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags = {
    Name = "Grafana-Subnet"
  }
}

# 3. Internet Gateway
resource "aws_internet_gateway" "grafana_igw" {
  vpc_id = aws_vpc.grafana_vpc.id
  tags = {
    Name = "Grafana-IGW"
  }
}

# 4. Route Table
resource "aws_route_table" "grafana_rt" {
  vpc_id = aws_vpc.grafana_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.grafana_igw.id
  }
  tags = {
    Name = "Grafana-RouteTable"
  }
}

# 5. Route Table Association
resource "aws_route_table_association" "grafana_rta" {
  subnet_id      = aws_subnet.grafana_subnet.id
  route_table_id = aws_route_table.grafana_rt.id
}

# 6. Security Group
resource "aws_security_group" "grafana_sg" {
  name_prefix = "grafana-"
  description = "Allow SSH and Grafana"
  vpc_id      = aws_vpc.grafana_vpc.id

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# 7. EC2 Instance
resource "aws_instance" "grafana" {
  ami                    = "ami-0c2b8ca1dad447f8a"
  instance_type          = "t2.micro"
  key_name               = "key" # Replace with your actual key name
  subnet_id              = aws_subnet.grafana_subnet.id
  vpc_security_group_ids = [aws_security_group.grafana_sg.id]

  user_data = <<-EOT
              #!/bin/bash
              apt update
              apt install -y python3
            EOT

  tags = {
    Name = "Grafana-Instance"
  }
}
