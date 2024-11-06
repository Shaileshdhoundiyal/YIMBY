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
resource "aws_instance" "yimby-prod-server" {
  ami                    = data.aws_ami.ubuntu-arm64.id
  instance_type          = "t4g.medium"
  key_name               = "yimby-prod-key"
  subnet_id              = module.yimby-prod-vpc.private_subnets[1]
  vpc_security_group_ids = [aws_security_group.yimby-prod-server-sg.id]

  iam_instance_profile = aws_iam_instance_profile.yimby-prod-instance-profile.name

  root_block_device {
    volume_size           = "40"
    volume_type           = "gp3"
    delete_on_termination = "false"

    tags = {
      Name    = "${local.name}-server-volume"
      Env     = local.tags.Env
      Project = local.tags.Project
    }

  }

  lifecycle {
    prevent_destroy = true
    ignore_changes = [
      ami
    ]
  }

  disable_api_termination = "true"


  user_data = <<-EOF
#!/bin/bash
sudo apt update -y
sudo apt install docker.io -y
sudo chmod 777 /var/run/docker.sock
sudo apt install unzip -y
curl "https://awscli.amazonaws.com/awscli-exe-linux-aarch64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
EOF

  tags = {
    Name    = "${local.name}-server"
    Env     = local.tags.Env
    Project = local.tags.Project
  }
}