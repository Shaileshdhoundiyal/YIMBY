resource "aws_instance" "yimby-qa-server" {
  ami                    = data.aws_ami.ubuntu-arm64.id
  instance_type          = "t4g.medium"
  key_name               = "yimby-qa-key"
  subnet_id              = module.yimby-qa-vpc.public_subnets[1]
  vpc_security_group_ids = [aws_security_group.yimby-qa-server-sg.id]

  iam_instance_profile = aws_iam_instance_profile.yimby-qa-instance-profile.name

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