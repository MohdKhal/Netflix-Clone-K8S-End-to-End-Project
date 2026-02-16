locals {
  instance_names = [
    "jenkins-server",
    "monitoring-server",
    "kubernetes-master-node",
    "kubernetes-worker-node"
  ]
}

resource "aws_instance" "ec2" {
  count = var.ec2_instance_count

  ami           = data.aws_ami.ubuntu.id
  subnet_id     = aws_subnet.public_subnet[count.index].id
  instance_type = var.ec2_instance_type[count.index]

  iam_instance_profile   = aws_iam_instance_profile.iam_instance_profile.name
  vpc_security_group_ids = [aws_security_group.default_ec2_sg.id]

  root_block_device {
    volume_size = var.ec2_volume_size
    volume_type = var.ec2_volume_type
  }

  user_data = count.index == 0 ? <<-EOT
#!/bin/bash
apt update -y
apt install -y openjdk-17-jdk wget
wget -O /home/ubuntu/jenkins.war https://get.jenkins.io/war-stable/latest/jenkins.war
chown ubuntu:ubuntu /home/ubuntu/jenkins.war
nohup java -Xms256m -Xmx512m -jar /home/ubuntu/jenkins.war --httpPort=8080 > /home/ubuntu/jenkins.log 2>&1 &
EOT
  : null

  tags = {
    Name = "${local.org}-${local.project}-${local.env}-${local.instance_names[count.index]}"
    Env  = local.env
  }
}
