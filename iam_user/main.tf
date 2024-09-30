provider "aws" {
  region = "ca-central-1" 
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

# Define Policies for Each User
data "aws_iam_policy_document" "custom_policy" {
  for_each = aws_iam_user.users
  
  statement {
    actions = lookup({
      aws       = ["s3:ListBucket", "ec2:DescribeInstances"],
      gcp       = ["s3:PutObject", "ec2:StartInstances"],
      azure     = ["s3:GetObject", "ec2:StopInstances"],
      terraform = ["s3:DeleteObject", "ec2:TerminateInstances"],
      cloud     = ["s3:ListObjects", "ec2:RebootInstances"]
    }, each.key, ["s3:ListBucket", "ec2:DescribeInstances"]) # Default policy for any user not listed
    resources = ["*"]
  }
}

# Attach Policies to Each User
resource "aws_iam_user_policy" "user_policy" {
  for_each = aws_iam_user.users
  name     = "custom-policy-${each.key}"
  user     = each.key
  policy   = data.aws_iam_policy_document.custom_policy[each.key].json
}

# Create Secrets Manager Secret to Store Passwords
resource "aws_secretsmanager_secret" "user_password_secret" {
  for_each = aws_iam_user.users
  name     = "${each.key}-password"
  description = "Password for ${each.key} user"
}

# Store Passwords in Secrets Manager
resource "aws_secretsmanager_secret_version" "user_password_version" {
  for_each = aws_iam_user.users
  secret_id     = aws_secretsmanager_secret.user_password_secret[each.key].id
  secret_string = random_password.user_password[each.key].result
}

output "iam_users" {
  value = {
    for user in aws_iam_access_key.user_access_key :
    user.user => {
      access_key_id     = user.id
      secret_access_key = user.secret
    }
  }
  sensitive = true  # Marking the output as sensitive
}

output "user_password_secrets" {
  value = {
    for user in aws_iam_user.users :
    user.name => aws_secretsmanager_secret.user_password_secret[user.name].id
  }
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
