provider "aws" {
  region = "ca-central-1"
}

# Define variables for user names and password settings
variable "user_names" {
  type    = list(string)
  default = ["aws", "gcp", "azure", "terraform", "cloud"]
}

variable "password_length" {
  description = "Length of the randomly generated passwords"
  type        = number
  default     = 16
}

variable "password_special_characters" {
  description = "Whether to include special characters in the password"
  type        = bool
  default     = true
}

# Create IAM Users
resource "aws_iam_user" "users" {
  for_each = toset(var.user_names)
  name     = each.key
}

# Generate Random Passwords for Each User
resource "random_password" "user_password" {
  for_each = aws_iam_user.users
  length   = var.password_length
  special  = var.password_special_characters
}

# Create Login Profile for Each User
resource "aws_iam_user_login_profile" "login_profile" {
  for_each               = aws_iam_user.users
  user                   = each.key
  password_reset_required = true
}

# Create Access Keys for Each User
resource "aws_iam_access_key" "user_access_key" {
  for_each = aws_iam_user.users
  user     = each.key
}

# Attach Different Managed Policies to Each User
resource "aws_iam_user_policy_attachment" "ec2_full_access" {
  for_each   = aws_iam_user.users
  user       = aws_iam_user.users["aws"].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
  depends_on = [aws_iam_user.users]
}

resource "aws_iam_user_policy_attachment" "s3_full_access" {
  for_each   = aws_iam_user.users
  user       = aws_iam_user.users["gcp"].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  depends_on = [aws_iam_user.users]
}

resource "aws_iam_user_policy_attachment" "iam_full_access" {
  for_each   = aws_iam_user.users
  user       = aws_iam_user.users["azure"].name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
  depends_on = [aws_iam_user.users]
}

resource "aws_iam_user_policy_attachment" "rds_full_access" {
  for_each   = aws_iam_user.users
  user       = aws_iam_user.users["terraform"].name
  policy_arn = "arn:aws:iam::aws:policy/AmazonRDSFullAccess"
  depends_on = [aws_iam_user.users]
}

resource "aws_iam_user_policy_attachment" "cloudwatch_full_access" {
  for_each   = aws_iam_user.users
  user       = aws_iam_user.users["cloud"].name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
  depends_on = [aws_iam_user.users]
}

# Create Secrets Manager Secret to Store Passwords
resource "aws_secretsmanager_secret" "user_password_secret" {
  for_each = aws_iam_user.users
   name     = "${each.key}-password-${random_string.suffix.result}"
}
resource "random_string" "suffix" {
  length  = 8
  special = false
}

# Store Passwords in Secrets Manager
resource "aws_secretsmanager_secret_version" "user_password_version" {
  for_each = aws_iam_user.users
  secret_id     = aws_secretsmanager_secret.user_password_secret[each.key].id
  secret_string = random_password.user_password[each.key].result
}

# Outputs
output "iam_users" {
  value = {
    for user in aws_iam_access_key.user_access_key :
    user.user => {
      access_key_id     = user.id
      secret_access_key = user.secret
    }
  }
  sensitive = true
}

output "user_password_secrets" {
  value = {
    for user in aws_iam_user.users :
    user.name => aws_secretsmanager_secret.user_password_secret[user.name].id
  }
}
