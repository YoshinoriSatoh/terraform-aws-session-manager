output "session_manager_policy" {
  value = aws_iam_policy.session-manager
}

output "logging_bucket" {
  description = "logging bucket"
  value = aws_s3_bucket.logging
}

output "aws_cloudwatch_log_group" {
  description = "cloudwatch log group"
  value = aws_cloudwatch_log_group.logging
}
