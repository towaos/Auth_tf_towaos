variable "prefix" {
  description = "リソース名のプレフィックス"
  type        = string
}

variable "project_name" {
  description = "プロジェクト名"
  type        = string
}

# 共通Lambda設定
variable "runtime" {
  description = "Lambda関数のランタイム"
  type        = string
  default     = "nodejs18.x"
}

variable "timeout" {
  description = "Lambda関数のタイムアウト（秒）"
  type        = number
  default     = 30
}

variable "memory_size" {
  description = "Lambda関数のメモリサイズ（MB）"
  type        = number
  default     = 128
}

# Auth Lambda 固有の設定
variable "auth_lambda_filename" {
  description = "Auth Lambda関数のZIPファイルパス"
  type        = string
}

variable "lambda_role_arn" {
  description = "Auth Lambda実行ロールのARN"
  type        = string
}

variable "auth_lambda_handler" {
  description = "Auth Lambda関数のハンドラー"
  type        = string
}

variable "auth_lambda_environment_variables" {
  description = "Auth Lambda関数の環境変数"
  type        = map(string)
  default     = {}
}

# JWT Lambda 固有の設定
variable "jwt_lambda_filename" {
  description = "JWT Lambda関数のZIPファイルパス"
  type        = string
}

variable "jwt_lambda_handler" {
  description = "JWT Lambda関数のハンドラー"
  type        = string
}

variable "jwt_lambda_environment_variables" {
  description = "JWT Lambda関数の環境変数"
  type        = map(string)
  default     = {}
}

# API Gateway ARN（API Gatewayモジュールを作成した場合に使用）
variable "auth_api_execution_arn" {
  description = "Auth API Gateway実行ARN"
  type        = string
  default     = ""
}

# タグ
variable "tags" {
  description = "リソースに付与するタグ"
  type        = map(string)
  default     = {}
}