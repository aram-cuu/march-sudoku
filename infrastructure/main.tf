terraform {
  required_version = ">= 1.0"

  cloud {
    organization = "aram-playground"

    workspaces {
      name = "march-sudoku-production"
    }
  }

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

locals {
  web_bucket_name       = "${var.project_name}-web-${var.environment}"
  artifacts_bucket_name = "${var.project_name}-artifacts-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
  }
}
