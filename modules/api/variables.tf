variable "prefix" {
  description = "リソース名のプレフィックス"
  type        = string
  default     = "app"
}

variable "create_api_gateway" {
  description = "API Gatewayを作成するかどうか"
  type        = bool
  default     = false
}

variable "api_gateway_routes" {
  description = "API Gatewayのルート設定"
  type = map(object({
    method              = string
    authorization       = string
    parent_resource_id  = string
  }))
  default = {}
}

variable "api_stage_name" {
  description = "API Gatewayのステージ名"
  type        = string
  default     = "dev"
}

variable "enable_cors" {
  description = "CORSを有効にするかどうか"
  type        = bool
  default     = true
}

variable "function_name" {
  description = "Lambda関数名"
  type        = string
}

variable "lambda_invoke_arn" {
  description = "Lambda関数の呼び出しARN"
  type        = string
}