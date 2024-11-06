terraform {
  backend "s3" {
    bucket         = "yimby-terraform.tfstate-backend-prod"
    key            = "terraform/terraform.tfstate"
    region         = "us-east-1"
    profile        = "YIMBY"
    dynamodb_table = "yimby-terraform.tfstate-backend-state-locking-prod"
  }
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region  = local.region
  profile = var.profile
}