terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    
    #for running ansible
    null = {
      source = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "aws" {
  region = "us-east-1"
}

# Use the default VPC instead of creating a new one
data "aws_vpc" "default" {
  default = true
}

# Security Group for the minecraft server: SSH for maintainece and 25565 for minecraft
resource "aws_security_group" "server" {
  name        = "mc_sec_group"
  description = "server: SSH and minecraft"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port = 25565
    to_port = 25565
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
    }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "mc_sec_group"
  }
}


# Minecraft server ec2 instance
resource "aws_instance" "mc_server" {
  ami                    = var.ami_id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.server.id]
  iam_instance_profile   = "LabInstanceProfile"
  associate_public_ip_address = true

  tags = {
    Name = "mc_server"
  }
}




# Run Ansible after Terraform provisioning
resource "null_resource" "ansible" {

 depends_on = [
    aws_instance.mc_server
  ]

  provisioner "local-exec" {

    command = <<EOT
sleep 60

ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook \
  -i '${aws_instance.mc_server.public_ip},' \
  --user ubuntu \
  --private-key ~/Downloads/${var.key_name}.pem \
  ansible/setup-k3s.yaml
EOT

  }
}