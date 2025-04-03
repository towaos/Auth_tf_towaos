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