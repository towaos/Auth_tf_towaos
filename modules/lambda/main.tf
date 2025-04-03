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

# auth_lambdaへの権限設定
resource "aws_lambda_permission" "auth_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvokeAuth"
  action        = "lambda:InvokeFunction"
  function_name = module.auth_lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  
  # API Gatewayからのリクエストのみを許可
  source_arn = "${var.auth_api_execution_arn}/*/POST/auth"
}

# jwt_lambdaへの権限設定
resource "aws_lambda_permission" "jwt_lambda_permission" {
  statement_id  = "AllowAPIGatewayInvokeJwt"
  action        = "lambda:InvokeFunction"
  function_name = module.jwt_lambda.lambda_function_name
  principal     = "apigateway.amazonaws.com"
  
  # API Gatewayからのリクエストのみを許可
  source_arn = "${var.auth_api_execution_arn}/*/POST/jwt-validation"
}