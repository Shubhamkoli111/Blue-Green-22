resource "aws_s3_bucket" "lambda_bucket" {
  bucket = lower(join("-", [replace(local.name, "_", "-"), "lambda-bucket213"]))
}

resource "aws_s3_bucket_acl" "lambda_bucket" {
  bucket = aws_s3_bucket.lambda_bucket.id
  acl    = "public-read"
}

resource "aws_s3_bucket_versioning" "lambda_bucket" {
  bucket = aws_s3_bucket.lambda_bucket.id
  versioning_configuration {
    status = "Disabled"
  }
}

resource "aws_s3_bucket_policy" "lambda_bucket_policy" {
  bucket = aws_s3_bucket.lambda_bucket.bucket
  policy = data.aws_iam_policy_document.lambda_bucket_policy.json
}

data "aws_iam_policy_document" "lambda_bucket_policy" {
  statement {
    sid       = "put"
    actions   = ["s3:*Object*"]
    resources = ["${aws_s3_bucket.lambda_bucket.arn}/*"]
    principals {
      identifiers = [aws_iam_role.lambda_role.arn]
      type        = "AWS"
    }
    condition {
      test     = "StringEquals"
      values   = ["bucket-owner-full-control"]
      variable = "s3:x-amz-acl"
    }
  }
}
