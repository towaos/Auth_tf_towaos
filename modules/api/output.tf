output "auth_api_id" {
  description = "認証API Gateway ID"
  value       = module.auth_api.api_id
}

output "auth_api_endpoint" {
  description = "認証API Gateway エンドポイント"
  value       = module.auth_api.api_endpoint
}

output "auth_api_execution_arn" {
  description = "認証API Gateway 実行ARN"
  value       = module.auth_api.execution_arn
}

output "jwt_api_id" {
  description = "JWT API Gateway ID"
  value       = module.jwt_api.api_id
}

output "jwt_api_endpoint" {
  description = "JWT API Gateway エンドポイント"
  value       = module.jwt_api.api_endpoint
}

output "jwt_api_execution_arn" {
  description = "JWT API Gateway 実行ARN"
  value       = module.jwt_api.execution_arn
}