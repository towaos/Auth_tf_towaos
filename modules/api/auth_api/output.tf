output "api_id" {
  description = "API Gateway ID"
  value       = aws_api_gateway_rest_api.api.id
}

output "api_endpoint" {
  description = "API Gateway エンドポイント"
  value       = "${aws_api_gateway_deployment.api_deployment.invoke_url}${aws_api_gateway_stage.api_stage.stage_name}"
}

output "execution_arn" {
  description = "API Gateway 実行ARN"
  value       = aws_api_gateway_rest_api.api.execution_arn
}