resource "aws_s3_bucket" "s3" {
    bucket = "balajiiii"
    
  
}
resource "aws_s3_bucket_versioning" "name" {
    bucket = aws_s3_bucket.s3.id
    versioning_configuration {
      status = "Enabled"
    }
  
}