
resource "aws_s3_bucket" "csv_bucket" {
  bucket = "csv-batch-bucket"
}

data "aws_iam_policy_document" "firehose_assume" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["firehose.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "firehose_role" {
  name               = "firehose_to_s3_role"
  assume_role_policy = data.aws_iam_policy_document.firehose_assume.json
}

data "aws_iam_policy_document" "firehose_s3_policy" {
  statement {
    effect    = "Allow"
    actions   = ["s3:*"]
    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "firehose_s3" {
  name   = "firehose_s3_policy"
  role   = aws_iam_role.firehose_role.id
  policy = data.aws_iam_policy_document.firehose_s3_policy.json
}

###############################################################################
# 3) Kinesis Data Stream (fonte)
###############################################################################
resource "aws_kinesis_stream" "csv_stream" {
  name             = "csv-stream"
  shard_count      = 1
  retention_period = 24
}

###############################################################################
# 4) Firehose → S3
###############################################################################
resource "aws_kinesis_firehose_delivery_stream" "csv_firehose" {
  name        = "csv-firehose"
  destination = "extended_s3"
  depends_on  = [aws_s3_bucket.csv_bucket, aws_iam_role_policy.firehose_s3]


  kinesis_source_configuration {
    kinesis_stream_arn = aws_kinesis_stream.csv_stream.arn
    role_arn           = aws_iam_role.firehose_role.arn
  }

  extended_s3_configuration {
    role_arn   = aws_iam_role.firehose_role.arn
    bucket_arn = aws_s3_bucket.csv_bucket.arn

    prefix              = "landing/" # pasta
    buffering_size      = 5          # MB
    buffering_interval  = 60         # s
    compression_format  = "UNCOMPRESSED"
    error_output_prefix = "errors/!{firehose:yyyy/MM/dd}/"
  }
}

###############################################################################
# 5) Outputs úteis
###############################################################################
output "stream_name" { value = aws_kinesis_stream.csv_stream.name }
output "firehose_name" { value = aws_kinesis_firehose_delivery_stream.csv_firehose.name }
output "bucket_name" { value = aws_s3_bucket.csv_bucket.bucket }
