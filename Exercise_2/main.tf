provider "aws" {
  shared_credentials_file = "~/.aws/credentials"
  profile                 = "terraform"
  region = var.aws_region
}

resource "aws_iam_role" "iam_for_lambda" {
  name = "iam_for_lambda"
  description = "IAM Role for greet_lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_policy" "lambda_cloud_watch" {
  name        = "lambda_cloud_watch"
  path        = "/"
  description = "IAM Policy for greet_lambda"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "lambda_logs" {
  role       = aws_iam_role.iam_for_lambda.name
  policy_arn = aws_iam_policy.lambda_cloud_watch.arn
}

resource "aws_cloudwatch_log_group" "example" {
  name              = "/aws/lambda/greet_lambda"
  retention_in_days = 14
}

data "archive_file" "zip" {
  type        = "zip"
  source_file = "greet_lambda.py"
  output_path = "greet_lambda.zip"
}

resource "aws_lambda_function" "lambda" {
  function_name = "greet_lambda"
  description = "greet_lambda"

  filename         = data.archive_file.zip.output_path
  source_code_hash = data.archive_file.zip.output_base64sha256

  role    = aws_iam_role.iam_for_lambda.arn
  handler = "greet_lambda.lambda_handler"
  runtime = "python3.7"

  environment {
    variables = {
      greeting = "Hoi hoi allemaal"
    }
  }
}
