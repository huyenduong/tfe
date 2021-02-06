terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

# Provider in htduong01 aws account
provider "aws" {
    profile = "htduong01_terraform"
    region = var.aws_default_region
}

resource "aws_instance" "ubuntu01" {
  ami = var.ubuntu_ami
  instance_type = "t2.micro"
  vpc_security_group_ids = [aws_security_group.ubuntu_sg.id]
  user_data = <<-EOF
              #!/bin/bash
              echo "Hello, World" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  tags = {
    Name = "ubuntu01"
    Creator = "terraform"
  }
}

resource "aws_security_group" "ubuntu_sg" {
  name = "ubuntu_sg"

  ingress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}