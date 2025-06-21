provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "grafana" {
  ami           = "ami-0c2b8ca1dad447f8a"
  instance_type = "t2.micro"
  key_name      = "AKIAR7HWXWTQKF5LVNYJ"
  tags = {
    Name = "Grafana-Instance"
  }

  vpc_security_group_ids = [aws_security_group.grafana_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              apt update
              apt install -y python3
              EOF
}

resource "aws_security_group" "grafana_sg" {
  name_prefix = "grafana-"
  ingress {
    from_port   = 3000
    to_port     = 3000
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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
