# Define variables for user names and password settings
variable "user_names" {
  type    = list(string)
  default = ["aws", "gcp", "azure", "terraform", "cloud"]
}

variable "user_policies" {
  type = map(string)
  default = {
    "aws"       = "arn:aws:iam::aws:policy/AdministratorAccess"
    "gcp"       = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    "azure"     = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
    "terraform" = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
    "cloud"     = "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
  }
}

