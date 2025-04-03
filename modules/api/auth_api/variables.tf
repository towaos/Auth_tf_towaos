variable "prefix" {
  description = "リソース名のプレフィックス"
  type        = string
}

variable "api_name" {
  description = "API Gateway名"
  type        = string
}

variable "api_gateway_routes" {
  description = "Auth API Gatewayルート設定"
  type = map(object({
    method              = string
    authorization       = string
    parent_resource_id  = optional(string)
    lambda_invoke_arn   = string
  }))
}

variable "lambda_invoke_arn" {
  description = "Lambda関数の呼び出しARN"
  type        = string
}

variable "enable_cors" {
  description = "CORSを有効にするかどうか"
  type        = bool
  default     = true
}

variable "api_stage_name" {
  description = "APIステージ名"
  type        = string
  default     = "dev"
}