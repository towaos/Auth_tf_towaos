# AWS設定
variable "aws_region" {
  description = "AWS リージョン"
  type        = string
  default     = "ap-northeast-1"
}

variable "aws_profile" {
  description = "AWS プロファイル"
  type        = string
  default     = "default"
}

# 基本設定
variable "prefix" {
  description = "リソース名のプレフィックス"
  type        = string
  default     = "app"
}

variable "project_name" {
  description = "プロジェクト名"
  type        = string
}

variable "environment" {
  description = "環境名"
  type        = string
  default     = "dev"
}

variable function_name {
  type        = string
  default     = ""
  description = "description"
}


# Cognito設定
variable "password_policy" {
  description = "パスワードポリシー"
  type = object({
    minimum_length    = number
    require_lowercase = bool
    require_uppercase = bool
    require_numbers   = bool
    require_symbols   = bool
  })
  default = {
    minimum_length    = 8
    require_lowercase = true
    require_uppercase = true
    require_numbers   = true
    require_symbols   = true
  }
}

variable "mfa_configuration" {
  description = "MFA設定"
  type        = string
  default     = "OFF"
}

variable "auto_verified_attributes" {
  description = "自動検証する属性"
  type        = list(string)
  default     = ["email"]
}

variable "schema_attributes" {
  description = "ユーザープールのスキーマ属性"
  type        = list(map(string))
  default     = []
}

variable "read_attributes" {
  description = "読み取り可能な属性"
  type        = list(string)
  default     = ["email", "email_verified", "name"]
}

variable "write_attributes" {
  description = "書き込み可能な属性"
  type        = list(string)
  default     = ["email", "name"]
}

variable "callback_urls" {
  description = "コールバックURL"
  type        = list(string)
  default     = ["https://localhost:3000/callback"]
}

variable "logout_urls" {
  description = "ログアウトURL"
  type        = list(string)
  default     = ["https://localhost:3000/logout"]
}

variable "create_identity_pool" {
  description = "アイデンティティプールを作成するかどうか"
  type        = bool
  default     = true
}

# IAM設定
variable "custom_policy" {
  description = "カスタムポリシー"
  type        = string
  default     = ""
}

# Lambda設定
variable "auth_lambda_filename" {
  description = "Auth Lambda関数のZIPファイルパス"
  type        = string
  default     = "../../functions/auth_function/func.zip"
}

variable "auth_lambda_handler" {
  description = "Auth Lambda関数のハンドラー"
  type        = string
  default     = "main"
}

variable "jwt_lambda_filename" {
  description = "JWT Lambda関数のZIPファイルパス"
  type        = string
  default     = "../../functions/jwt_function/func.zip"
}

variable "jwt_lambda_handler" {
  description = "JWT Lambda関数のハンドラー"
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

# API Gateway設定
variable "auth_api_gateway_routes" {
  description = "Auth API Gatewayルート設定"
  type = map(object({
    method           = string
    authorization    = string
    parent_resource_id = optional(string)
  }))
  default = {
    "auth" = {
      method = "POST"
      authorization = "NONE"
    }
    "login" = {
      method = "POST"
      authorization = "NONE"
    }
    "register" = {
      method = "POST"
      authorization = "NONE"
    }
  }
}

variable api_stage_name {
  type        = string
  default     = ""
  description = "description"
}


variable "jwt_api_gateway_routes" {
  description = "JWT API Gatewayルート設定"
  type = map(object({
    method           = string
    authorization    = string
    parent_resource_id = optional(string)
  }))
  default = {
    "token" = {
      method = "POST"
      authorization = "NONE"
    }
    "verify" = {
      method = "POST"
      authorization = "NONE"
    }
    "refresh" = {
      method = "POST"
      authorization = "NONE"
    }
  }
}

variable "enable_cors" {
  description = "CORSを有効にするかどうか"
  type        = bool
  default     = true
}