# 共通変数
variable "aws_region" {
  description = "AWSリージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "aws_profile" {
  description = "AWS プロファイル名"
  type        = string
  default     = "default"
}

variable "prefix" {
  description = "リソース名のプレフィックス"
  type        = string
  default     = "app"
}

variable "environment" {
  description = "デプロイ環境（dev, staging, prod など）"
  type        = string
  default     = "dev"
}

# Cognito関連変数
variable "password_policy" {
  description = "パスワードポリシーの設定"
  type = object({
    minimum_length    = number
    require_lowercase = bool
    require_numbers   = bool
    require_symbols   = bool
    require_uppercase = bool
  })
  default = {
    minimum_length    = 8
    require_lowercase = true
    require_numbers   = true
    require_symbols   = true
    require_uppercase = true
  }
}

variable "mfa_configuration" {
  description = "MFA設定（OFF, OPTIONAL, REQUIRED）"
  type        = string
  default     = "OPTIONAL"
}

variable "auto_verified_attributes" {
  description = "自動検証属性のリスト"
  type        = list(string)
  default     = ["email"]
}

variable "schema_attributes" {
  description = "ユーザー属性のスキーマ"
  type = list(object({
    name                = string
    attribute_data_type = string
    mutable             = bool
    required            = bool
  }))
  default = [
    {
      name                = "email"
      attribute_data_type = "String"
      mutable             = true
      required            = true
    }
  ]
}

variable "read_attributes" {
  description = "読み取り可能な属性のリスト"
  type        = list(string)
  default     = ["email", "email_verified", "preferred_username"]
}

variable "write_attributes" {
  description = "書き込み可能な属性のリスト"
  type        = list(string)
  default     = ["email", "preferred_username"]
}

variable "callback_urls" {
  description = "コールバックURL"
  type        = list(string)
  default     = ["http://localhost:3000/callback"]
}

variable "logout_urls" {
  description = "ログアウトURL"
  type        = list(string)
  default     = ["http://localhost:3000"]
}

variable "create_identity_pool" {
  description = "IDプールを作成するかどうか"
  type        = bool
  default     = false
}

# Lambda関連変数
variable "lambda_filename" {
  description = "Lambda関数のZIPファイルパス"
  type        = string
}

variable "lambda_handler" {
  description = "Lambda関数のハンドラー"
  type        = string
  default     = "main"
}

variable "lambda_runtime" {
  description = "Lambda関数のランタイム"
  type        = string
  default     = "go1.x"
}

variable "lambda_timeout" {
  description = "Lambda関数のタイムアウト（秒）"
  type        = number
  default     = 10
}

variable "lambda_memory_size" {
  description = "Lambda関数のメモリサイズ（MB）"
  type        = number
  default     = 128
}

variable "lambda_environment_variables" {
  description = "Lambda関数の環境変数"
  type        = map(string)
  default     = {}
}

variable "lambda_custom_policy" {
  description = "Lambdaのカスタムポリシー（JSON形式）"
  type        = string
  default     = null
}

# IAM関連変数
variable "cognito_actions" {
  description = "Cognitoに対する許可アクション"
  type        = list(string)
  default     = null
}

variable "custom_policies" {
  description = "追加のカスタムIAMポリシー"
  type        = map(string)
  default     = {}
}

# API Gateway関連変数
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

variable "enable_cors" {
  description = "CORSを有効にするかどうか"
  type        = bool
  default     = true
}