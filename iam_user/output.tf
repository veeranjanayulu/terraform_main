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