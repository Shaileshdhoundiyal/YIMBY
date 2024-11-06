data "aws_secretsmanager_secret_version" "yimby-qa-rds-secrets" {
  secret_id = "yimby-qa-rds-secrets"
}

module "yimby-qa-rds-db" {
  source = "terraform-aws-modules/rds/aws"

  identifier = "${local.name}-rds-db"

  engine                = "mysql"
  engine_version        = "8.0.33"
  instance_class        = "db.t4g.micro"
  allocated_storage     = 10
  max_allocated_storage = 50

  db_name                     = "yimbydb"
  username                    = local.rds_db_creds.username
  password                    = local.rds_db_creds.password
  manage_master_user_password = false
  port                        = "3306"
  publicly_accessible         = false

  iam_database_authentication_enabled = false

  apply_immediately = true

  vpc_security_group_ids = [aws_security_group.yimby-qa-rds-sg.id]

  maintenance_window = "Mon:01:30-Mon:04:30"
  backup_window      = "04:30-07:30"

  blue_green_update = {
    enabled = true
  }

  enabled_cloudwatch_logs_exports = ["general", "error"]
  create_cloudwatch_log_group     = true

  # DB subnet group
  create_db_subnet_group = true
  subnet_ids             = module.yimby-qa-vpc.database_subnets

  # DB parameter group
  family = "mysql8.0"

  # DB option group
  major_engine_version = "8.0"

  deletion_protection = true


  copy_tags_to_snapshot = true
  tags                  = local.tags
}