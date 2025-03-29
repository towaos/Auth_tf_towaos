terraform {
  required_version = ">= 1.0.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

# Cognito User Pool
resource "aws_cognito_user_pool" "main" {
  name = var.user_pool_name
  
  # Password Policy
  password_policy {
    minimum_length    = var.password_policy.minimum_length
    require_lowercase = var.password_policy.require_lowercase
    require_numbers   = var.password_policy.require_numbers
    require_symbols   = var.password_policy.require_symbols
    require_uppercase = var.password_policy.require_uppercase
  }
  
  mfa_configuration = var.mfa_configuration
  
  auto_verified_attributes = var.auto_verified_attributes
  
  email_configuration {
    email_sending_account = var.email_sending_account
  }
  
  # Schema Definition
  dynamic "schema" {
    for_each = var.schema_attributes
    content {
      name                = schema.value.name
      attribute_data_type = schema.value.attribute_data_type
      mutable             = schema.value.mutable
      required            = schema.value.required
    }
  }
  
  read_attributes = var.read_attributes
  write_attributes = var.write_attributes
}

# Cognitoクライアントアプリの設定
resource "aws_cognito_user_pool_client" "client" {
  name                   = var.client_name
  user_pool_id           = aws_cognito_user_pool.main.id
  generate_secret        = var.generate_secret
  refresh_token_validity = var.refresh_token_validity
  access_token_validity  = var.access_token_validity
  id_token_validity      = var.id_token_validity
  
  explicit_auth_flows = var.explicit_auth_flows
  
  token_validity_units {
    access_token  = var.token_validity_units.access_token
    id_token      = var.token_validity_units.id_token
    refresh_token = var.token_validity_units.refresh_token
  }
  
  allowed_oauth_flows_user_pool_client = var.allowed_oauth_flows_user_pool_client
  allowed_oauth_flows                  = var.allowed_oauth_flows
  allowed_oauth_scopes                 = var.allowed_oauth_scopes
  callback_urls                        = var.callback_urls
  logout_urls                          = var.logout_urls
  supported_identity_providers         = var.supported_identity_providers
  prevent_user_existence_errors        = var.prevent_user_existence_errors
}

# IDプールの作成（オプション）
resource "aws_cognito_identity_pool" "main" {
  count = var.create_identity_pool ? 1 : 0
  
  identity_pool_name               = var.identity_pool_name
  allow_unauthenticated_identities = var.allow_unauthenticated_identities
  
  cognito_identity_providers {
    client_id               = aws_cognito_user_pool_client.client.id
    provider_name           = aws_cognito_user_pool.main.endpoint
    server_side_token_check = true
  }
}

# IDプールとロールの関連付け
resource "aws_cognito_identity_pool_roles_attachment" "main" {
  count = var.create_identity_pool ? 1 : 0
  
  identity_pool_id = aws_cognito_identity_pool.main[0].id
  
  roles = {
    "authenticated" = aws_iam_role.authenticated[0].arn
  }
}