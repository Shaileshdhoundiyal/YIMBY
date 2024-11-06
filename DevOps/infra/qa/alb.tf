module "yimby-qa-alb" {
  source  = "terraform-aws-modules/alb/aws"

  name = "yimby-qa-alb"
  vpc_id = module.yimby-qa-vpc.vpc_id
  subnets = module.yimby-qa-vpc.public_subnets
  internal = false
  create = false
  ip_address_type = "ipv4"
  load_balancer_type = "application"
  create_security_group = false
  security_groups = [aws_security_group.yimby-qa-alb-sg.id]




  tags = local.tags
}