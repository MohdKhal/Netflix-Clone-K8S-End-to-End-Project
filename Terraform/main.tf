terraform {
  required_version = "~> 1.12.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 6.14.1"
    }
  }

  cloud {
    organization = "ibrahim-khaleel"

    workspaces {
      name = "netflix-clone-project"
    }
  }
}

provider "aws" {
  region = var.aws-region
}

# =========================
# AMI DATA
# =========================

data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name = "name"
    values = [
      "ubuntu/images/hvm-ssd/ubuntu-noble-24.04-amd64-server-*"
    ]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}

# =========================
# LOCALS
# =========================

locals {
  org     = "aman"
  project = "netflix-clone"
  env     = var.env

  instance_names = [
    "jenkins-server",
    "monitoring-server",
    "kubernetes-master-node",
    "kubernetes-worker-node"
  ]
}

# =========================
# EC2 INSTANCES
# =========================

resource "aws_instance" "ec2" {
  count = var.ec2-instance-count

  ami           = data.aws_ami.ubuntu.id
  subnet_id     = aws_subnet.public-subnet[count.index].id
  instance_type = var.ec2_instance_type[count.index]

  iam_instance_profile   = aws_iam_instance_profile.iam-instance-profile.name
  vpc_security_group_ids = [aws_security_group.default-ec2-sg.id]

  root_block_device {
    volume_size = var.ec2_volume_size
    volume_type = var.ec2_volume_type
  }

  # Install Jenkins ONLY on first instance
  user_data = count.index == 0 ? <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y openjdk-17-jdk wget

              wget -O /home/ubuntu/jenkins.war https://get.jenkins.io/war-stable/latest/jenkins.war
              chown ubuntu:ubuntu /home/ubuntu/jenkins.war

              nohup java -Xms256m -Xmx512m -jar /home/ubuntu/jenkins.war --httpPort=8080 > /home/ubuntu/jenkins.log 2>&1 &
              EOF
              : null

  tags = {
    Name = "${local.org}-${local.project}-${local.env}-${local.instance_names[count.index]}"
    Env  = local.env
  }
}
