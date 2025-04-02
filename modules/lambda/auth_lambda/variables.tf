# 共通変数
variable "prefix" {
  description = "リソース名のプレフィックス"
  type        = string
  default     = "app"
}

variable "tags" {
  description = "リソースに付与するタグ"
  type        = map(string)
  default     = {}
}

# Lambda関連変数
variable "function_name" {
  description = "Lambda関数名"
  type        = string
}

variable "filename" {
  description = "Lambda関数のZIPファイルパス"
  type        = string
}

variable "handler" {
  description = "Lambda関数のハンドラー"
  type        = string
  default     = "main"
}

variable "runtime" {
  description = "Lambda関数のランタイム"
  type        = string
  default     = "go1.x"
}

variable "timeout" {
  description = "Lambda関数のタイムアウト（秒）"
  type        = number
  default     = 10
}

variable "memory_size" {
  description = "Lambda関数のメモリサイズ（MB）"
  type        = number
  default     = 128
}

variable "environment_variables" {
  description = "Lambda関数の環境変数"
  type        = map(string)
  default     = {}
}

variable lambda_role_arn {
  type        = string
  default     = ""
  description = "description"
}

variable api_gateway_execution_arn {
  type        = string
  default     = ""
  description = "description"
}
