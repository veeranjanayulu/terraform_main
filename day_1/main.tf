resource "aws_s3_bucket" "bucket1" {
    for_each = toset(var.aws_buckets)
    bucket = each.value
    tags = {
      Name="mybucket"
      enviroment ="deve"
    }
  
}