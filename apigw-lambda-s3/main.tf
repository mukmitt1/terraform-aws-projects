#################################
# Local variables
#################################

locals {
  required_tags = {
    project     = var.project_name,
    environment = var.environment
  }

  tags = merge(var.resource_tags, local.required_tags)
  name_suffix = "${var.project_name}-${var.environment}"
}



#################################
# IAM Role and policy for Lambda
#################################

resource "aws_iam_role" "lambda_trust_role" {
  name   = "lambda_Policy_Function_Role"
  assume_role_policy = file(var.lambda_role)
  tags = local.tags
}

resource "aws_iam_policy" "iam_policy_for_lambda" {
 name         = "aws_iam_policy_for_terraform_aws_lambda_role"
 description  = "AWS IAM Policy for managing aws lambda role"
 policy = file(var.lambda_role_policy)
 tags = local.tags
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 role        = aws_iam_role.lambda_trust_role.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}

provider "aws" {
  region = var.aws_region
}


#################################
# Lambda Creation
#################################

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/python/"
  output_path = "${path.module}/python/ag-python.zip"
}


resource "aws_lambda_function" "terraform_lambda_func" {
filename                       = "${path.module}/python/ag-python.zip"
function_name                  = "lambda_${local.name_suffix}"
role                           = aws_iam_role.lambda_trust_role.arn
handler                        = "index.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
tags = local.tags
}


#################################
# DynamoDB
#################################

resource "aws_dynamodb_table" "agbtable" {
  name             = "lambda-apigateway"
  hash_key         = "id"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  attribute {
  name = "executionId"
  type = "S"
  }
  tags = local.tags
}

#################################
# API Gateway
#################################

resource "aws_api_gateway_rest_api" "example" {
  name        = "ServerlessExample"
  description = "Terraform Serverless Application Example"
}

resource "aws_api_gateway_resource" "proxy" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  parent_id   = "${aws_api_gateway_rest_api.example.root_resource_id}"
  path_part   = "{proxy+}"
}

resource "aws_api_gateway_method" "proxy" {
  rest_api_id   = "${aws_api_gateway_rest_api.example.id}"
  resource_id   = "${aws_api_gateway_resource.proxy.id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  resource_id = "${aws_api_gateway_method.proxy.resource_id}"
  http_method = "${aws_api_gateway_method.proxy.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.terraform_lambda_func.arn}"
}

resource "aws_api_gateway_method" "proxy_root" {
  rest_api_id   = "${aws_api_gateway_rest_api.example.id}"
  resource_id   = "${aws_api_gateway_rest_api.example.root_resource_id}"
  http_method   = "ANY"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "lambda_root" {
  rest_api_id = "${aws_api_gateway_rest_api.example.id}"
  resource_id = "${aws_api_gateway_method.proxy_root.resource_id}"
  http_method = "${aws_api_gateway_method.proxy_root.http_method}"

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = "${aws_lambda_function.terraform_lambda_func.arn}"
}
