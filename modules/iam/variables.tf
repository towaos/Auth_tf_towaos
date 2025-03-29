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

# IAM関連変数
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
  type        = string
  default     = null
}
