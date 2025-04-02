output "auth_lambda_function_name" {
  description = "認証Lambda関数名"
  value       = module.auth_lambda.lambda_function_name
}

output "auth_lambda_function_arn" {
  description = "認証Lambda関数ARN"
  value       = module.auth_lambda.lambda_function_arn
}

output "auth_lambda_invoke_arn" {
  description = "認証Lambda関数呼び出しARN"
  value       = module.auth_lambda.lambda_invoke_arn
}

output "jwt_lambda_function_name" {
  description = "JWT Lambda関数名"
  value       = module.jwt_lambda.lambda_function_name
}

output "jwt_lambda_function_arn" {
  description = "JWT Lambda関数ARN"
  value       = module.jwt_lambda.lambda_function_arn
}

output "jwt_lambda_invoke_arn" {
  description = "JWT Lambda関数呼び出しARN"
  value       = module.jwt_lambda.lambda_invoke_arn
}