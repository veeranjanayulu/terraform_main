resource "aws_s3_bucket" "bucket" {
    for_each = toset(var.aws_buckets)
    bucket = each.value
    tags = {
      Name="mybucket"
      enviroment ="deve"
    }
  
}
resource "aws_s3_bucket_versioning" "bucket" {
  
  bucket = aws_s3_bucket.bucket["shriiii"].bucket
  versioning_configuration {
    status = "Enabled"
  }
  
}