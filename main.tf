/**
 * # Terraform AWS Session manager module
 *
 * SystemsManagerのSessionManagerを使用する際にEC2インスタンスに必要な権限を含めたIAMポリシーと、ログ関連リソースを作成します。
 */

data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

# Session ManagerのIAM Policyは以下を参照
# https://docs.aws.amazon.com/ja_jp/systems-manager/latest/userguide/getting-started-create-iam-instance-profile.html
resource "aws_iam_policy" "session_manager" {
  name        = "${var.tf.fullname}-session-manager"
  description = "${var.tf.fullname}-session-manager"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Effect" : "Allow",
        "Action" : [
          "ssm:UpdateInstanceInformation",
          "ssmmessages:CreateControlChannel",
          "ssmmessages:CreateDataChannel",
          "ssmmessages:OpenControlChannel",
          "ssmmessages:OpenDataChannel"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "logs:CreateLogStream",
          "logs:PutLogEvents",
          "logs:DescribeLogGroups",
          "logs:DescribeLogStreams"
        ],
        "Resource" : "*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:PutObject"
        ],
        "Resource" : "${aws_s3_bucket.logging.arn}/*"
      },
      {
        "Effect" : "Allow",
        "Action" : [
          "s3:GetEncryptionConfiguration"
        ],
        "Resource" : "*"
      }
    ]
  })
}

resource "aws_cloudwatch_log_group" "logging" {
  name              = "${var.tf.fullname}-session-manager-logs"
  retention_in_days = 0
}

resource "aws_s3_bucket" "logging" {
  bucket        = "${var.tf.fullname}-session-manager-logs"
  force_destroy = var.in_development
}

resource "aws_s3_bucket_server_side_encryption_configuration" "logging" {
  bucket = aws_s3_bucket.logging.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "logging" {
  bucket                  = aws_s3_bucket.logging.id
  block_public_acls       = true
  ignore_public_acls      = true
  block_public_policy     = true
  restrict_public_buckets = true
  depends_on = [
    aws_s3_bucket.logging
  ]
}
