# IAM出力
output "lambda_role_name" {
  description = "Lambda実行ロール名"
  value       = aws_iam_role.lambda_role.name
}

output "lambda_role_arn" {
  description = "Lambda実行ロールARN"
  value       = aws_iam_role.lambda_role.arn
}