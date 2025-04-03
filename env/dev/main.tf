provider "aws" {
  alias   = "main"
  region  = var.aws_region
  profile = var.aws_profile
}

module "cognito" {
  source = "../../modules/cognito"
  
  prefix        = var.prefix
  user_pool_name = "${var.prefix}-${var.project_name}-user-pool"
  client_name   = "${var.prefix}-${var.project_name}-client"
  
  password_policy = var.password_policy
  mfa_configuration = var.mfa_configuration
  auto_verified_attributes = var.auto_verified_attributes
  
  schema_attributes = var.schema_attributes
  read_attributes = var.read_attributes
  write_attributes = var.write_attributes
  
  callback_urls = var.callback_urls
  logout_urls = var.logout_urls
  
  create_identity_pool = var.create_identity_pool
  identity_pool_name = "${var.prefix}-${var.project_name}-identity-pool"

  providers = {
    aws = aws.main
  }
}

module "iam" {
  source = "../../modules/iam"
  
  prefix = var.prefix
  function_name = var.function_name
    
  # Cognito認証設定
  cognito_user_pool_arn = module.cognito.user_pool_arn
  identity_pool_id = module.cognito.identity_pool_id
  create_identity_pool = var.create_identity_pool
  
  # カスタムポリシー
  custom_policy = var.custom_policy
  
  providers = {
    aws = aws.main
  }
}

module "lambda" {
  source = "../../modules/lambda"
  
  prefix = var.prefix
  project_name = var.project_name
  
  # Auth Lambda設定
  auth_lambda_filename = var.auth_lambda_filename
  auth_lambda_handler = var.auth_lambda_handler
  auth_lambda_environment_variables = {
    COGNITO_REGION = var.aws_region
    COGNITO_USER_POOL_ID = module.cognito.user_pool_id
    COGNITO_CLIENT_ID = module.cognito.client_id
  }
  
  # JWT Lambda設定
  jwt_lambda_filename = var.jwt_lambda_filename
  jwt_lambda_handler = var.jwt_lambda_handler
  jwt_lambda_environment_variables = {
    COGNITO_REGION = var.aws_region
    COGNITO_USER_POOL_ID = module.cognito.user_pool_id
    COGNITO_CLIENT_ID = module.cognito.client_id
  }
  
  # 共通設定
  lambda_role_arn = module.iam.lambda_role_arn
  runtime = var.lambda_runtime
  timeout = var.lambda_timeout
  memory_size = var.lambda_memory_size
  
  # API Gateway ARNは初期状態では空に（循環依存を避けるため）
  auth_api_execution_arn = module.api.auth_api_execution_arn
  
  tags = local.common_tags
  
  providers = {
    aws = aws.main
  }
}

module "api" {
  source = "../../modules/api"
  
  # 基本設定
  prefix = var.prefix
  project_name = var.project_name
  
  # APIルート設定
  auth_api_gateway_routes = {
    "auth" = {
      method           = "POST"
      authorization    = "NONE"
      lambda_invoke_arn = module.lambda.auth_lambda_invoke_arn
    },
    "jwt-validation" = {
      method           = "POST"
      authorization    = "NONE"
      lambda_invoke_arn = module.lambda.jwt_lambda_invoke_arn
    }
  }
  api_stage_name = var.api_stage_name

  # CORS設定
  enable_cors = var.enable_cors
    
  tags = local.common_tags
  
  providers = {
    aws = aws.main
  }
}

# # Lambda権限の設定（循環依存を回避するため別モジュールで）
# module "lambda_permissions" {
#   source = "../../modules/lambda_permissions"
  
#   auth_lambda_function_name = module.lambda.auth_lambda_function_name
#   jwt_lambda_function_name = module.lambda.jwt_lambda_function_name
  
#   auth_api_execution_arn = module.api.auth_api_execution_arn
#   jwt_api_execution_arn = module.api.jwt_api_execution_arn
  
#   providers = {
#     aws = aws.main
#   }
  
#   depends_on = [
#     module.lambda,
#     module.api
#   ]
# }

# 共通タグ
locals {
  common_tags = {
    Environment = var.environment
    Project     = var.project_name
    ManagedBy   = "terraform"
  }
}