# API Gateway出力
output "api_gateway_id" {
  description = "API Gateway ID"
  value       = var.create_api_gateway ? aws_api_gateway_rest_api.api[0].id : null
}

output "api_gateway_root_resource_id" {
  description = "API Gatewayルートリソース ID"
  value       = var.create_api_gateway ? aws_api_gateway_rest_api.api[0].root_resource_id : null
}

output "api_gateway_execution_arn" {
  description = "API Gateway実行ARN"
  value       = var.create_api_gateway ? aws_api_gateway_rest_api.api[0].execution_arn : null
}

output "api_url" {
  description = "APIのURL"
  value       = var.create_api_gateway ? "${aws_api_gateway_stage.api_stage[0].invoke_url}" : null
}