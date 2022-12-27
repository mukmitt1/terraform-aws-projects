resource "aws_iam_role" "lambda_trust_role" {
  name   = "lambda_Policy_Function_Role"
  assume_role_policy = file("others/assume_role_policy.json")
}

resource "aws_iam_policy" "iam_policy_for_lambda" {
 name         = "aws_iam_policy_for_terraform_aws_lambda_role"
 description  = "AWS IAM Policy for managing aws lambda role"
 policy = file("others/policy.json")
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 role        = aws_iam_role.lambda_trust_role.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}

provider "aws" {
  region = var.aws_region
  }

resource "aws_dynamodb_table" "ddbtable" {
  name             = "order"
  hash_key         = "executionId"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  attribute {
  name = "executionId"
  type = "S"
  }
}

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/python/"
  output_path = "${path.module}/python/hello-python.zip"
}


resource "aws_lambda_function" "terraform_lambda_func" {
filename                       = "${path.module}/python/hello-python.zip"
function_name                  = "My_Lambda_Function"
role                           = aws_iam_role.lambda_trust_role.arn
handler                        = "index.lambda_handler"
runtime                        = "python3.9"
depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}
