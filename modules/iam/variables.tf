# 共通変数
variable "prefix" {
  description = "リソース名のプレフィックス"
  type        = string
  default     = "app"
}

# IAM関連変数
variable create_identity_pool {
  type        = bool
  default     = false
  description = "IDプールを作成するかどうか"
}

variable identity_pool_id {
  type        = string
  default     = ""
  description = "description"
}

variable function_name {
  type        = string
  default     = ""
  description = "description"
}

variable "cognito_user_pool_arn" {
  description = "Cognito User Pool ARN"
  type        = string
  default     = null
}

variable "cognito_actions" {
  description = "Cognitoに対する許可アクション"
  type        = list(string)
  default     = null
}

variable "custom_policy" {
  description = "カスタムポリシーJSON"
  type        = any
  default     = {}
}
