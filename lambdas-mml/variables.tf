variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "lambda_role" {
description = "Lambda assume role"
type        = string
default     = "others/assume_role_policy.json"
}

variable "lambda_role_policy" {
description = "Lambda execution policy"
type        = string
default     = "others/policy.json"
}
