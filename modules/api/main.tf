terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Auth API モジュール
module "auth_api" {
  source = "./auth_api"
  
  prefix            = var.prefix
  api_name          = "${var.project_name}-api"
  api_gateway_routes = var.auth_api_gateway_routes
  lambda_invoke_arn = var.auth_lambda_invoke_arn
  enable_cors       = var.enable_cors
  api_stage_name    = var.api_stage_name
}