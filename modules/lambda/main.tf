terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Auth Lambda モジュール
module "auth_lambda" {
  source = "./auth_lambda"
  
  prefix                = var.prefix
  function_name         = "${var.project_name}-auth"
  filename              = var.auth_lambda_filename
  lambda_role_arn              = var.lambda_role_arn
  handler               = var.auth_lambda_handler
  runtime               = var.runtime
  timeout               = var.timeout
  memory_size           = var.memory_size
  environment_variables = var.auth_lambda_environment_variables
  tags                  = var.tags
}

# JWT Lambda モジュール
module "jwt_lambda" {
  source = "./jwt_lambda"
  
  prefix                = var.prefix
  function_name         = "${var.project_name}-jwt"
  filename              = var.jwt_lambda_filename
  lambda_role_arn              = var.lambda_role_arn
  handler               = var.jwt_lambda_handler
  runtime               = var.runtime
  timeout               = var.timeout
  memory_size           = var.memory_size
  environment_variables = var.jwt_lambda_environment_variables
  tags                  = var.tags
}

# API Gateway用の権限設定（必要に応じて）
resource "aws_lambda_permission" "auth_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.auth_lambda.lambda_function_name  # function_name から lambda_function_name に修正
  principal     = "apigateway.amazonaws.com"
  
  # API Gatewayからのリクエストのみを許可（後でAPI Gatewayモジュールを作成した場合）
  source_arn = var.auth_api_gateway_execution_arn
}

resource "aws_lambda_permission" "jwt_api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = module.jwt_lambda.lambda_function_name  # function_name から lambda_function_name に修正
  principal     = "apigateway.amazonaws.com"
  
  # API Gatewayからのリクエストのみを許可（後でAPI Gatewayモジュールを作成した場合）
  source_arn = var.jwt_api_gateway_execution_arn
}