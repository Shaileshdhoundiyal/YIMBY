# deleted on 5th-Dec-2023
/*resource "aws_eip" "yimby-qa-jenkins-eip" {
  domain = "vpc"
  tags = {
    Name    = "${local.name}-jenkins-eip"
    Env     = local.tags.Env
    Project = local.tags.Project
  }
}

resource "aws_eip_association" "yimby-qa-jenkins-eip-association" {
  instance_id   = aws_instance.yimby-qa-jenkins.id
  allocation_id = aws_eip.yimby-qa-jenkins-eip.id
}*/

resource "aws_eip" "yimby-qa-server-eip" {
  domain = "vpc"
  tags = {
    Name    = "${local.name}-server-eip"
    Env     = local.tags.Env
    Project = local.tags.Project
  }
}

resource "aws_eip_association" "yimby-qa-server-eip-association" {
  instance_id   = aws_instance.yimby-qa-server.id
  allocation_id = aws_eip.yimby-qa-server-eip.id
}