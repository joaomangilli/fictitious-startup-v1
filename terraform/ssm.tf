resource "aws_ssm_parameter" "secret_key" {
  name  = "/cloudtalents/startup/secret_key"
  type  = "SecureString"
  value = "bar"

  lifecycle {
    ignore_changes = ["value"]
  }
}

resource "aws_ssm_parameter" "db_user" {
  name  = "/cloudtalents/startup/db_user"
  type  = "SecureString"
  value = "bar"

  lifecycle {
    ignore_changes = ["value"]
  }
}

resource "aws_ssm_parameter" "db_password" {
  name  = "/cloudtalents/startup/db_password"
  type  = "SecureString"
  value = "bar"

  lifecycle {
    ignore_changes = ["value"]
  }
}

resource "aws_ssm_parameter" "database_endpoint" {
  name  = "/cloudtalents/startup/database_endpoint"
  type  = "String"
  value = aws_db_instance.postgres.address
}

resource "aws_ssm_parameter" "image_storage_bucket_name" {
  name  = "/cloudtalents/startup/image_storage_bucket_name"
  type  = "String"
  value = aws_s3_bucket.assets.id
}

resource "aws_ssm_parameter" "image_storage_cloudfront_domain" {
  name  = "/cloudtalents/startup/image_storage_cloudfront_domain"
  type  = "String"
  value = aws_cloudfront_distribution.assets.domain_name
}
