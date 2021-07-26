terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 2.70"
    }
  }
}

provider "aws" {
   access_key = "AKIAUFITGSV6KYNEHFUR"

  secret_key = "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"
  
  region     = "ap-south-1"
}
resource "aws_vpc" "vpc" {
  cidr_block       = "10.0.0.0/16"
  instance_tenancy = "default"

  tags = {
    Name = "nishanth_vpc_1"
  }
}
resource "aws_subnet" "Pub" {
  vpc_id     = aws_vpc.vpc.id
  cidr_block = "10.0.1.0/24"

  tags = {
    Name = "Public"
  }
}

resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.vpc.id

  tags = {
    Name = "IGW"
  }
}
resource "aws_eip" "ip" {
    vpc  = true
}

resource "aws_route_table" "rt1" {
  vpc_id = aws_vpc.vpc.id

  route  {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = {
      name = "task_route"
  }
}


resource "aws_route_table_association" "as_1" {
  subnet_id      = aws_subnet.Pub.id
  route_table_id = aws_route_table.rt1.id
}
resource "aws_security_group" "sg" {
  name        = "first-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id

  ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]

  }
 egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fisrst-sg"
  }
}


resource "aws_instance" "ubuntu_1" {
  ami  = "ami-0c1a7f89451184c8b"
  instance_type = "t2.micro"
      user_data = <<-EOF
      #!/bin/bash
      sudo apt update
      sudo apt install -y apache2
      sudo apt install -y ansible
      EOF
  associate_public_ip_address = true
  subnet_id = aws_subnet.Pub.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = "nishanthkey"
 tags = {
    Name = "ansible_server"
  }

  }
  resource "aws_security_group" "sg_1" {
  name        = "secound-sg"
  description = "Allow TLS inbound traffic"
  vpc_id      = aws_vpc.vpc.id
    ingress {
    description      = "TLS from VPC"
    from_port        = 80
    to_port          = 80
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
   }
    ingress {
    description      = "TLS from VPC"
    from_port        = 22
    to_port          = 22
    protocol         = "tcp"
    cidr_blocks      = ["0.0.0.0/0"]
  }

 egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name = "ansible-sg"
  }
}

resource "aws_instance" "ubuntu2" {
  ami  = "ami-0c1a7f89451184c8b"
  instance_type = "t2.micro"
      user_data = <<-EOF
      #!/bin/bash
      sudo apt update
      sudo apt install -y apache2
      EOF
  associate_public_ip_address = true
  subnet_id = aws_subnet.Pub.id
  vpc_security_group_ids = [aws_security_group.sg_1.id]
  key_name               = "nishanthkey"
 tags = {
    Name = "apache_server"
  }

}
resource "aws_instance" "ubuntu_3" {
  ami  = "ami-0c1a7f89451184c8b"
  instance_type = "t3.micro"
      user_data = <<-EOF
      #!/bin/bash
      sudo apt update
      sudo apt install -y apache2
      EOF
  associate_public_ip_address = true
  subnet_id = aws_subnet.Pub.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = "nishanthkey"
 tags = {
    Name = "k8worker_server"
  }
}
resource "aws_instance" "ubuntu_4" {
  ami  = "ami-0c1a7f89451184c8b"
  instance_type = "t3.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.Pub.id
  vpc_security_group_ids = [aws_security_group.sg.id]
  key_name               = "nishanthkey"
 tags = {
    Name = "k8master_server"
  }
}
