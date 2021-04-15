resource "aws_dynamodb_table" "daily_cat_photos_sampling_statistics" {
  name           = "daily_cat_photos_sampling_statistics"
  billing_mode   = "PROVISIONED"
  read_capacity  = 5
  write_capacity = 5
  hash_key       = "photo_id"
  range_key      = "request_timestamp"

  attribute {
    name = "photo_id"
    type = "N"
  }

  attribute {
    name = "request_timestamp"
    type = "S"
  }

  lifecycle {
    prevent_destroy = true
  }
}
