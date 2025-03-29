terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# API Gateway統合
resource "aws_api_gateway_rest_api" "api" {
  count       = var.create_api_gateway ? 1 : 0
  name        = "${var.prefix}-${var.function_name}-api"
  description = "${var.function_name} API"
}

# リソースとメソッドを動的に作成
resource "aws_api_gateway_resource" "api_resources" {
  for_each    = var.create_api_gateway ? var.api_gateway_routes : {}
  
  rest_api_id = aws_api_gateway_rest_api.api[0].id
  parent_id   = each.value.parent_resource_id != null ? each.value.parent_resource_id : aws_api_gateway_rest_api.api[0].root_resource_id
  path_part   = each.key
}

# 各リソースにメソッドとインテグレーションを作成
resource "aws_api_gateway_method" "api_methods" {
  for_each    = var.create_api_gateway ? var.api_gateway_routes : {}
  
  rest_api_id   = aws_api_gateway_rest_api.api[0].id
  resource_id   = aws_api_gateway_resource.api_resources[each.key].id
  http_method   = each.value.method
  authorization_type = each.value.authorization
}

resource "aws_api_gateway_integration" "api_integrations" {
  for_each    = var.create_api_gateway ? var.api_gateway_routes : {}
  
  rest_api_id             = aws_api_gateway_rest_api.api[0].id
  resource_id             = aws_api_gateway_resource.api_resources[each.key].id
  http_method             = aws_api_gateway_method.api_methods[each.key].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.lambda.invoke_arn
}

# CORSサポート
resource "aws_api_gateway_method" "options_methods" {
  for_each    = var.create_api_gateway && var.enable_cors ? var.api_gateway_routes : {}
  
  rest_api_id   = aws_api_gateway_rest_api.api[0].id
  resource_id   = aws_api_gateway_resource.api_resources[each.key].id
  http_method   = "OPTIONS"
  authorization_type = "NONE"
}

resource "aws_api_gateway_integration" "options_integrations" {
  for_each    = var.create_api_gateway && var.enable_cors ? var.api_gateway_routes : {}
  
  rest_api_id      = aws_api_gateway_rest_api.api[0].id
  resource_id      = aws_api_gateway_resource.api_resources[each.key].id
  http_method      = aws_api_gateway_method.options_methods[each.key].http_method
  type             = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_responses" {
  for_each    = var.create_api_gateway && var.enable_cors ? var.api_gateway_routes : {}
  
  rest_api_id   = aws_api_gateway_rest_api.api[0].id
  resource_id   = aws_api_gateway_resource.api_resources[each.key].id
  http_method   = aws_api_gateway_method.options_methods[each.key].http_method
  status_code   = "200"
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = true,
    "method.response.header.Access-Control-Allow-Methods" = true,
    "method.response.header.Access-Control-Allow-Origin"  = true
  }
}

resource "aws_api_gateway_integration_response" "options_integration_responses" {
  for_each    = var.create_api_gateway && var.enable_cors ? var.api_gateway_routes : {}
  
  rest_api_id   = aws_api_gateway_rest_api.api[0].id
  resource_id   = aws_api_gateway_resource.api_resources[each.key].id
  http_method   = aws_api_gateway_method.options_methods[each.key].http_method
  status_code   = aws_api_gateway_method_response.options_responses[each.key].status_code
  
  response_parameters = {
    "method.response.header.Access-Control-Allow-Headers" = "'Content-Type,X-Amz-Date,Authorization,X-Api-Key,X-Amz-Security-Token'",
    "method.response.header.Access-Control-Allow-Methods" = "'GET,OPTIONS,POST,PUT,DELETE'",
    "method.response.header.Access-Control-Allow-Origin"  = "'*'"
  }
}

# APIデプロイメント
resource "aws_api_gateway_deployment" "api_deployment" {
  count       = var.create_api_gateway ? 1 : 0
  depends_on  = [aws_api_gateway_integration.api_integrations]
  
  rest_api_id = aws_api_gateway_rest_api.api[0].id
}

# APIステージ
resource "aws_api_gateway_stage" "api_stage" {
  count       = var.create_api_gateway ? 1 : 0
  
  deployment_id = aws_api_gateway_deployment.api_deployment[0].id
  rest_api_id   = aws_api_gateway_rest_api.api[0].id
  stage_name    = var.api_stage_name
}