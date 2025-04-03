variable prefix {
  type        = string
  default     = ""
  description = "description"
}

variable project_name {
  type        = string
  default     = ""
  description = "description"
}


variable "auth_api_gateway_routes" {
  description = "Auth API Gatewayルート設定"
  type = map(object({
    method              = string
    authorization       = string
    parent_resource_id  = optional(string)
    lambda_invoke_arn   = string
  }))
}

# API Gateway 共通設定
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

# タグ
variable "tags" {
  description = "リソースに付与するタグ"
  type        = map(string)
  default     = {}
}

variable auth_lambda_invoke_arn {
  type        = string
  default     = ""
  description = "description"
}