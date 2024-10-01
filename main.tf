provider "aws" {
  region = "ca-central-1"
}
locals {
  user_policies = {
    "aws"       = "arn:aws:iam::aws:policy/AdministratorAccess"
    "gcp"       = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
    "azure"     = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
    "terraform" = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
    "cloud"     = "arn:aws:iam::aws:policy/AWSCloudFormationFullAccess"
  }
}

# Define variables for user names
variable "user_names" {
  type    = list(string)
  default = ["aws", "gcp", "azure", "terraform", "cloud"]
}

# Create IAM Users
resource "aws_iam_user" "users" {
  for_each = toset(var.user_names)
  name     = each.key
}

# Create Login Profile for Each User
resource "aws_iam_user_login_profile" "login_profile" {
  for_each                = aws_iam_user.users
  user                    = each.key
  password_reset_required = true  # Users will need to reset their passwords on first login
}

# Create Access Keys for Each User (for API/CLI access)
resource "aws_iam_access_key" "user_access_key" {
  for_each = aws_iam_user.users
  user     = each.key
}

# Attach IAMFullAccess policy to all users temporarily for troubleshooting
resource "aws_iam_user_policy_attachment" "full_access_policy" {
  for_each  = aws_iam_user.users
  user      = each.key
  policy_arn = local.user_policies[each.key]
}

# Outputs for access keys
output "iam_users" {
  value = {
    for user in aws_iam_access_key.user_access_key :
    user.user => {
      access_key_id     = user.id
      secret_access_key = user.secret
    }
  }
  sensitive = true  # Marking as sensitive to protect access keys
}
