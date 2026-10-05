data "aws_caller_identity" "current" {}

locals {
  world_bucket_name = "${var.project}-world-${data.aws_caller_identity.current.account_id}"
}

resource "aws_s3_bucket" "world" {
  bucket = local.world_bucket_name

  tags = {
    Project = var.project
  }
}

resource "aws_s3_bucket_versioning" "world" {
  bucket = aws_s3_bucket.world.id

  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "world" {
  bucket = aws_s3_bucket.world.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "world" {
  bucket = aws_s3_bucket.world.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}