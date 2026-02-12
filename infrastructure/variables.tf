variable "project_name" {
  description = "Name of the project"
  type        = string
  default     = "march-sudoku"
}

variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "production"
}

variable "AWS_ACCESS_KEY_ID" {
  type      = string
  default   = ""
  sensitive = true
}

variable "AWS_SECRET_ACCESS_KEY" {
  type      = string
  default   = ""
  sensitive = true
}

variable "AWS_REGION" {
  type    = string
  default = ""
}
