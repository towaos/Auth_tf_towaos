terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Cognito認証済みユーザー用IAMロール
resource "aws_iam_role" "authenticated" {
  count = var.create_identity_pool ? 1 : 0
  
  name = "${var.prefix}-cognito-authenticated"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        }
        Action = "sts:AssumeRoleWithWebIdentity"
        Condition = {
          StringEquals = {
            "cognito-identity.amazonaws.com:aud" = var.identity_pool_id
          }
          "ForAnyValue:StringLike" = {
            "cognito-identity.amazonaws.com:amr" = "authenticated"
          }
        }
      }
    ]
  })
}

# Lambda用IAMロール
resource "aws_iam_role" "lambda_role" {
  name = "${var.prefix}_${var.function_name}_role"
  
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })
}

# Lambda基本実行ポリシー
resource "aws_iam_policy" "lambda_basic_policy" {
  name        = "${var.prefix}_${var.function_name}_basic_policy"
  description = "基本的なLambda実行権限"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Effect   = "Allow"
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

# Cognito操作用ポリシー
resource "aws_iam_policy" "cognito_policy" {
  count       = var.cognito_actions != null ? 1 : 0
  name        = "${var.prefix}_${var.function_name}_cognito_policy"
  description = "Cognito操作権限"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action   = var.cognito_actions
        Effect   = "Allow"
        Resource = var.cognito_user_pool_arn
      }
    ]
  })
}

# カスタムポリシー
resource "aws_iam_policy" "custom_policy" {
  count       = var.custom_policy != null ? 1 : 0
  name        = "${var.prefix}_${var.function_name}_custom_policy"
  description = "カスタムポリシー"
  
  policy = var.custom_policy
}

# ポリシーとロールの関連付け
resource "aws_iam_role_policy_attachment" "basic_policy_attachment" {
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.lambda_basic_policy.arn
}

resource "aws_iam_role_policy_attachment" "cognito_policy_attachment" {
  count      = var.cognito_actions != null ? 1 : 0
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.cognito_policy[0].arn
}

resource "aws_iam_role_policy_attachment" "custom_policy_attachment" {
  count      = var.custom_policy != null ? 1 : 0
  role       = aws_iam_role.lambda_role.name
  policy_arn = aws_iam_policy.custom_policy[0].arn
}

# IDプールとロールの関連付け
resource "aws_cognito_identity_pool_roles_attachment" "main" {
  count = var.create_identity_pool ? 1 : 0
  
  identity_pool_id = var.identity_pool_id
  roles = {
    "authenticated" = aws_iam_role.authenticated[0].arn
  }
}