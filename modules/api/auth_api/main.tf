# API Gateway REST API
resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.prefix}-${var.api_name}"
  description = "${var.api_name} API"
}

# リソースとメソッドを動的に作成
resource "aws_api_gateway_resource" "api_resources" {
  for_each    = var.api_gateway_routes
  
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = each.value.parent_resource_id != null ? each.value.parent_resource_id : aws_api_gateway_rest_api.api.root_resource_id
  path_part   = each.key
}

# 各リソースにメソッドとインテグレーションを作成
resource "aws_api_gateway_method" "api_methods" {
  for_each    = var.api_gateway_routes
  
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.api_resources[each.key].id
  http_method   = each.value.method
  authorization = each.value.authorization
}

resource "aws_api_gateway_integration" "api_integrations" {
  for_each    = var.api_gateway_routes
  
  rest_api_id             = aws_api_gateway_rest_api.api.id
  resource_id             = aws_api_gateway_resource.api_resources[each.key].id
  http_method             = aws_api_gateway_method.api_methods[each.key].http_method
  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = var.lambda_invoke_arn
}

# CORSサポート
resource "aws_api_gateway_method" "options_methods" {
  for_each    = var.enable_cors ? var.api_gateway_routes : {}
  
  rest_api_id   = aws_api_gateway_rest_api.api.id
  resource_id   = aws_api_gateway_resource.api_resources[each.key].id
  http_method   = "OPTIONS"
  authorization = "NONE"
}

resource "aws_api_gateway_integration" "options_integrations" {
  for_each    = var.enable_cors ? var.api_gateway_routes : {}
  
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.api_resources[each.key].id
  http_method      = aws_api_gateway_method.options_methods[each.key].http_method
  type             = "MOCK"
  request_templates = {
    "application/json" = "{\"statusCode\": 200}"
  }
}

resource "aws_api_gateway_method_response" "options_responses" {
  for_each    = var.enable_cors ? var.api_gateway_routes : {}
  
  rest_api_id   = aws_api_gateway_rest_api.api.id
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
  for_each    = var.enable_cors ? var.api_gateway_routes : {}
  
  rest_api_id   = aws_api_gateway_rest_api.api.id
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
  depends_on  = [aws_api_gateway_integration.api_integrations]
  
  rest_api_id = aws_api_gateway_rest_api.api.id
  
  # デプロイメントがリソース変更時に更新されるようにするためのトリガー
  triggers = {
    redeployment = sha1(jsonencode([
      for resource in aws_api_gateway_resource.api_resources : {
        id = resource.id
        path = resource.path_part
      }
    ]))
  }
  
  lifecycle {
    create_before_destroy = true
  }
}

# APIステージ
resource "aws_api_gateway_stage" "api_stage" {
  deployment_id = aws_api_gateway_deployment.api_deployment.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.api_stage_name
}