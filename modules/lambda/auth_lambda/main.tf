terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Lambda関数の定義
resource "aws_lambda_function" "lambda" {
  function_name    = "${var.prefix}-${var.function_name}"
  filename         = var.filename
  source_code_hash = filebase64sha256(var.filename)
  role             = var.lambda_role_arn
  handler          = var.handler
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.memory_size
  
  environment {
    variables = var.environment_variables
  }

  tags = var.tags
}