data "aws_ami" "ubuntu-arm64" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-arm64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}
# deleted on 5th-Dec-2023
/*resource "aws_instance" "yimby-qa-jenkins" {
  ami                    = data.aws_ami.ubuntu-arm64.id
  instance_type          = "t4g.medium"
  key_name               = "yimby-qa-key"
  subnet_id              = module.yimby-qa-vpc.public_subnets[0]
  vpc_security_group_ids = [aws_security_group.yimby-qa-jenkins-sg.id]


  iam_instance_profile = aws_iam_instance_profile.yimby-qa-instance-profile.name

  root_block_device {
    volume_size           = "40"
    volume_type           = "gp3"
    delete_on_termination = "true"

    tags = {
      Name    = "${local.name}-jenkins-volume"
      Env     = local.tags.Env
      Project = local.tags.Project
    }

  }

  lifecycle {
    prevent_destroy = false
    ignore_changes = [
      ami
    ]
  }

  disable_api_termination = "true"


  user_data = <<-EOF
                #!/bin/bash
                sudo apt update -y
                sudo apt-get install openjdk-17-jdk -y
                wget -q -O - https://pkg.jenkins.io/debian/jenkins-ci.org.key | sudo apt-key add -
                sudo sh -c 'echo deb http://pkg.jenkins.io/debian-stable binary/ > /etc/apt/sources.list.d/jenkins.list'
                sudo apt update -y && sudo apt upgrade -y
                sudo apt install jenkins -y
                sudo systemctl start jenkins
                sudo systemctl enable jenkins

                sudo apt install docker.io -y
                sudo chmod 777 /var/run/docker.sock

                sudo apt install unzip -y

                curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
                unzip awscliv2.zip
                sudo ./aws/install
                
                EOF

  tags = {
    Name    = "${local.name}-jenkins"
    Env     = local.tags.Env
    Project = local.tags.Project
  }
}*/