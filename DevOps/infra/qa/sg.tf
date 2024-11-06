## Security group for RDS instance.

resource "aws_security_group" "yimby-qa-rds-sg" {
  name        = "${local.name}-rds-sg"
  description = "Security group that opens port 3306 for mySQL."
  vpc_id      = module.yimby-qa-vpc.vpc_id

  ingress {
    description = "Allowing mysql access from VPCs."
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    cidr_blocks = ["${local.vpc_cidr}"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}

# deleted on 5th-Dec-2023
## Security group for Jenkins instance.

/*resource "aws_security_group" "yimby-qa-jenkins-sg" {
  name        = "${local.name}-jenkins-sg"
  description = "Security group that opens port 22 for SSH and port 8080 for JENKINS."
  vpc_id      = module.yimby-qa-vpc.vpc_id

  ingress {
    description = "Allowing SSH access from VPCs."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.vpc_cidr}"]
  }

  ingress {
    description = "Allowing jenkins from anywhere."
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}*/

## Security group for qa-server instance.

resource "aws_security_group" "yimby-qa-server-sg" {
  name        = "${local.name}-server-sg"
  description = "Security group that opens port 22 for SSH and port 80 for frontend."
  vpc_id      = module.yimby-qa-vpc.vpc_id

  ingress {
    description = "Allowing SSH access from VPCs."
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["${local.vpc_cidr}"]
  }

  ingress {
    description = "Allowing frontend from Application Load Balancer Only."
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    security_groups = [aws_security_group.yimby-qa-alb-sg.id]
  }

  ingress {
    description = "Allowing Backend Traffic from Only yimby-qa-server-sg."
    from_port   = 4000
    to_port     = 4000
    protocol    = "tcp"
    self        = true
  }

  ingress {
    description = "Allowing SSH Access form Prod jenkins NAT Gateway"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["18.214.197.14/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}


## Security group for Application load balancer.

resource "aws_security_group" "yimby-qa-alb-sg" {
  name        = "${local.name}-alb-sg"
  description = "Security group for Application Load Balancer."
  vpc_id      = module.yimby-qa-vpc.vpc_id

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = local.tags
}