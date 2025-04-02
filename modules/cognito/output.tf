# Cognito出力
output "user_pool_id" {
  description = "Cognito User Pool ID"
  value       = aws_cognito_user_pool.main.id
}

output "user_pool_arn" {
  description = "Cognito User Pool ARN"
  value       = aws_cognito_user_pool.main.arn
}

output "user_pool_endpoint" {
  description = "Cognito User Pool エンドポイント"
  value       = aws_cognito_user_pool.main.endpoint
}

output "client_id" {
  description = "Cognito User Pool Client ID"
  value       = aws_cognito_user_pool_client.client.id
}

output "identity_pool_id" {
  description = "Cognito Identity Pool ID"
  value       = var.create_identity_pool ? aws_cognito_identity_pool.main[0].id : null
}