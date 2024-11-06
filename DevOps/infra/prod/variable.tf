locals {
  name     = "${var.project}-${var.environment}"
  region   = "us-east-1"
  vpc_cidr = "10.250.0.0/16"
  azs      = slice(data.aws_availability_zones.available.names, 0, 3)
  
  rds_db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.yimby-prod-rds-secrets.secret_string
  )

  tags = {
    Env     = var.environment
    Project = var.project
  }
}

variable "project" {
  description = "Name of Project"
  type        = string
  default     = "yimby"
}

variable "profile" {
  description = "Name of Profile"
  type        = string
  default     = "YIMBY"
}
variable "environment" {
  description = "Name for Environment"
  type        = string
  default     = "prod"
}

variable "ecr" {
  description = "Name of all ECR repositories."
  default     = ["yimby-prod-ecr-frontend", "yimby-prod-ecr-backend"]
}
