resource "aws_s3_bucket" "daily_cats_photos" {
  bucket = "daily-cats"
  acl    = "private"
}

# Note: normally s3 object as well as lambda code would be separated/deployed independently from terraform, but
# to simplify the example they're part of IaaC.
resource "aws_s3_bucket_object" "cat_photos_objects" {
  for_each = toset(fileset("${path.module}/cat_photos", "*.png"))
  bucket = aws_s3_bucket.daily_cats_photos.bucket
  key = each.value
  source = "${path.module}/cat_photos/${each.value}"
}
