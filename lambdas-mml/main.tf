resource "aws_iam_role" "lambda_role" {
  name   = "Spacelift_Test_Lambda_Function_Role"
  assume_role_policy = file("others/assume_role_policy.json")
}

resource "aws_iam_policy" "iam_policy_for_lambda" {
 name         = "aws_iam_policy_for_terraform_aws_lambda_role"
 description  = "AWS IAM Policy for managing aws lambda role"
 policy = file("others/policy.json")
}

resource "aws_iam_role_policy_attachment" "attach_iam_policy_to_iam_role" {
 role        = aws_iam_role.lambda_role.name
 policy_arn  = aws_iam_policy.iam_policy_for_lambda.arn
}

provider "aws" {
  region = var.aws_region
  }

data "archive_file" "zip_the_python_code" {
  type        = "zip"
  source_dir  = "${path.module}/python/"
  output_path = "${path.module}/python/hello-python.zip"
}


resource "aws_lambda_function" "terraform_lambda_func" {
filename                       = "${path.module}/python/hello-python.zip"
function_name                  = "Spacelift_Test_Lambda_Function"
role                           = aws_iam_role.lambda_role.arn
handler                        = "index.lambda_handler"
runtime                        = "python3.8"
depends_on                     = [aws_iam_role_policy_attachment.attach_iam_policy_to_iam_role]
}
