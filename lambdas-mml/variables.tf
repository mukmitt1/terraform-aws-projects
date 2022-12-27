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

variable "lambda_function_name" {
description = "Lambda function name"
type        = string
default     = "MyLambdaFunction"
}


################
# Step Function
################

variable "step_name" {
  description = "The name of the Step Function"
  type        = string
  default     = "sample-state-machine"
}

variable "step_definition" {
  description = "The Amazon States Language definition of the Step Function"
  type        = string
  default     = "others/step-functions-workflow.json"
}

variable "role_arn" {
  description = "The Amazon Resource Name (ARN) of the IAM role to use for this Step Function"
  type        = string
  default     = ""
}

variable "tags" {
  description = "Maps of tags to assign to the Step Function"
  type        = map(string)
  default     = {}
}

variable "type" {
  description = "Determines whether a Standard or Express state machine is created. The default is STANDARD. Valid Values: STANDARD | EXPRESS"
  type        = string
  default     = "STANDARD"

  validation {
    condition     = contains(["STANDARD", "EXPRESS"], upper(var.type))
    error_message = "Step Function type must be one of the following (STANDARD | EXPRESS)."
  }
}
