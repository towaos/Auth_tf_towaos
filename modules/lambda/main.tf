terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Lambda関数
resource "aws_lambda_function" "lambda" {
  function_name    = "${var.prefix}-${var.function_name}"
  filename         = var.filename
  source_code_hash = filebase64sha256(var.filename)
  role             = aws_iam_role.lambda_role.arn
  handler          = var.handler
  runtime          = var.runtime
  timeout          = var.timeout
  memory_size      = var.memory_size
  
  environment {
    variables = var.environment_variables
  }

  tags = var.tags
}

# Lambda関数のAPI Gateway呼び出し許可
resource "aws_lambda_permission" "api_gateway_lambda" {
  count          = var.create_api_gateway ? 1 : 0
  
  statement_id   = "AllowExecutionFromAPIGateway"
  action         = "lambda:InvokeFunction"
  function_name  = aws_lambda_function.lambda.function_name
  principal      = "apigateway.amazonaws.com"
  source_arn     = "${aws_api_gateway_rest_api.api[0].execution_arn}/*/*"
}