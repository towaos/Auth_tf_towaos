# Lambda出力
output "lambda_function_name" {
  description = "Lambda関数名"
  value       = aws_lambda_function.lambda.function_name
}

output "lambda_function_arn" {
  description = "Lambda関数ARN"
  value       = aws_lambda_function.lambda.arn
}

output "lambda_invoke_arn" {
  description = "Lambda関数の呼び出しARN"
  value       = aws_lambda_function.lambda.invoke_arn
}