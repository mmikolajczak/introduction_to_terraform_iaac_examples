# While normally one would rather avoid placing and deploying actual application code in terraform, this case
# is only single file/lambda that is rather not intended to change – and so, to simplify things following "get the
# job done" solution was picked.
locals {
  daily_cat_endpoint_source_module_relpath = "/get_daily_cat_endpoint_source"
  daily_cat_endpoint_zip_module_relpath = "/get_daily_cat_endpoint_lambda.zip"
}

data "archive_file" "daily_cat_endpoint_zip" {
  type        = "zip"
  source_dir  = "${path.module}${local.daily_cat_endpoint_source_module_relpath}"
  output_path = "${path.module}${local.daily_cat_endpoint_zip_module_relpath}"
}

resource "aws_lambda_function" "daily_cat_endpoint" {
  filename      = data.archive_file.daily_cat_endpoint_zip.output_path
  function_name = "daily_cat_endpoint"
  role          = aws_iam_role.daily_cat_endpoint_lambda.arn
  handler       = "lambda.lambda_handler"

  source_code_hash = data.archive_file.daily_cat_endpoint_zip.output_base64sha256

  runtime = "python3.8"

  environment {
    variables = {
      "CATS_PHOTOS_BUCKET": aws_s3_bucket.daily_cats_photos.bucket
      "MAX_PHOTO_ID": length(aws_s3_bucket_object.cat_photos_objects) - 1
      "SAMPLING_STATISTICS_TABLE_NAME": aws_dynamodb_table.random_cat_photos_sampling_statistics.name
    }
  }
}

resource "aws_iam_role" "daily_cat_endpoint_lambda" {
  name = "daily_cat_endpoint_lambda"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy" "daily_cat_endpoint_lambda_logging" {
  role = aws_iam_role.daily_cat_endpoint_lambda.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents"
      ],
      "Resource": "arn:aws:logs:*:*:*",
      "Effect": "Allow"
    }
  ]
}
EOF
}
# NOTE/TODO: resource might/should be more restrictive in the policy above.

resource "aws_iam_role_policy" "daily_cat_endpoint_lambda_allow_cat_photos_objects_s3_read" {
  role = aws_iam_role.daily_cat_endpoint_lambda.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
            "s3:GetObject*",
            "s3:HeadObject",
            "s3:ListObjects*"
          ],
          "Resource": [
            "${aws_s3_bucket.daily_cats_photos.arn}",
            "${aws_s3_bucket.daily_cats_photos.arn}/*"
          ]
      }
  ]
}
EOF
}

resource "aws_iam_role_policy" "daily_cat_endpoint_lambda_allow_dynamodb_cat_photos_sampling_statistics_write" {
  role = aws_iam_role.daily_cat_endpoint_lambda.name
  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
      {
          "Effect": "Allow",
          "Action": [
            "dynamodb:PutItem",
            "dynamodb:UpdateItem"
          ],
          "Resource": [
            "${aws_dynamodb_table.random_cat_photos_sampling_statistics.arn}"
          ]
      }
  ]
}
EOF
}
