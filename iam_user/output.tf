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
