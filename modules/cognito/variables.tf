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

# Cognito関連変数
variable "user_pool_name" {
  description = "Cognito User Poolの名前"
  type        = string
  default     = "auth-towaos"
}

variable "client_name" {
  description = "Cognito User Pool Clientの名前"
  type        = string
  default     = "app-client"
}

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
  default     = "OFF"
}

variable "auto_verified_attributes" {
  description = "自動検証属性のリスト"
  type        = list(string)
  default     = ["email"]
}

variable "email_sending_account" {
  description = "メール送信アカウント（COGNITO_DEFAULT, DEVELOPER）"
  type        = string
  default     = "COGNITO_DEFAULT"
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

variable "generate_secret" {
  description = "アプリクライアントシークレットを生成するかどうか"
  type        = bool
  default     = false
}

variable "refresh_token_validity" {
  description = "リフレッシュトークンの有効期間"
  type        = number
  default     = 30
}

variable "access_token_validity" {
  description = "アクセストークンの有効期間"
  type        = number
  default     = 1
}

variable "id_token_validity" {
  description = "IDトークンの有効期間"
  type        = number
  default     = 1
}

variable "explicit_auth_flows" {
  description = "認証フローの設定"
  type        = list(string)
  default     = ["ALLOW_USER_PASSWORD_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_SRP_AUTH"]
}

variable "token_validity_units" {
  description = "トークン有効期間の単位"
  type = object({
    access_token  = string
    id_token      = string
    refresh_token = string
  })
  default = {
    access_token  = "hours"
    id_token      = "hours"
    refresh_token = "days"
  }
}

variable "allowed_oauth_flows_user_pool_client" {
  description = "OAuthフローを許可するかどうか"
  type        = bool
  default     = true
}

variable "allowed_oauth_flows" {
  description = "許可するOAuthフロー"
  type        = list(string)
  default     = ["code", "implicit"]
}

variable "allowed_oauth_scopes" {
  description = "許可するOAuthスコープ"
  type        = list(string)
  default     = ["phone", "email", "openid", "profile", "aws.cognito.signin.user.admin"]
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

variable "supported_identity_providers" {
  description = "サポートするIDプロバイダー"
  type        = list(string)
  default     = ["COGNITO"]
}

variable "prevent_user_existence_errors" {
  description = "ユーザー存在エラーの防止"
  type        = string
  default     = "ENABLED"
}

variable "identity_pool_name" {
  description = "IDプールの名前"
  type        = string
  default     = "app-identity-pool"
}

variable "allow_unauthenticated_identities" {
  description = "未認証IDを許可するかどうか"
  type        = bool
  default     = false
}

variable "create_identity_pool" {
  description = "IDプールを作成するかどうか"
  type        = bool
  default     = false
}
