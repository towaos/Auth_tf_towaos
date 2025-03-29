provider "aws" {
  alias   = "main"
  region  = var.aws_region
  profile = var.aws_profile
}

module "cognito" {
  source = "../../modules/cognito"
  
  prefix        = var.prefix
  user_pool_name = "${var.prefix}-user-pool-${var.environment}"
  client_name   = "${var.prefix}-client-${var.environment}"
  
  password_policy = var.password_policy
  mfa_configuration = var.mfa_configuration
  auto_verified_attributes = var.auto_verified_attributes
  
  schema_attributes = var.schema_attributes
  read_attributes = var.read_attributes
  write_attributes = var.write_attributes
  
  callback_urls = var.callback_urls
  logout_urls = var.logout_urls
  
  create_identity_pool = var.create_identity_pool
  identity_pool_name = "${var.prefix}-identity-pool-${var.environment}"

  providers = {
    aws = aws.main
  }
}

module "lambda" {
  source = "../../modules/lambda"
  
  prefix = var.prefix
  function_name = "${var.prefix}-function-${var.environment}"
  filename = var.lambda_filename
  handler = var.lambda_handler
  runtime = var.lambda_runtime
  timeout = var.lambda_timeout
  memory_size = var.lambda_memory_size
  environment_variables = var.lambda_environment_variables
  
  # API Gateway統合用の設定
  create_api_gateway = var.create_api_gateway
  
  # Cognitoモジュールからの出力を利用
  cognito_user_pool_arn = module.cognito.user_pool_arn
  cognito_actions = var.cognito_actions
  
  # カスタムポリシーがあれば設定
  custom_policy = var.lambda_custom_policy
  
  providers = {
    aws = aws.main
  }
}

module "api" {
  source = "../../modules/api"
  
  # 基本設定
  prefix = var.prefix
  create_api_gateway = var.create_api_gateway
  
  # APIルート設定
  api_gateway_routes = var.api_gateway_routes
  api_stage_name = var.environment
  
  # CORS設定
  enable_cors = var.enable_cors
  
  # Lambda関数との統合（Lambdaのモジュール出力を使用）
  # APIモジュールで対応する変数名に変更
  function_name = module.lambda.lambda_function_name
  lambda_invoke_arn = module.lambda.lambda_invoke_arn
  
  providers = {
    aws = aws.main
  }
}
module "iam" {
  source = "../../modules/iam"
  
  prefix = var.prefix
  environment = var.environment
  
  # Lambdaロール設定
  lambda_function_name = module.lambda.lambda_function_name
  
  # Cognito認証設定
  cognito_user_pool_arn = module.cognito.user_pool_arn
  identity_pool_id = module.cognito.identity_pool_id
  create_identity_pool = var.create_identity_pool
  
  # カスタムポリシー
  custom_policies = var.custom_policies
  
  providers = {
    aws = aws.main
  }
}