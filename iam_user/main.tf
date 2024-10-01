resource "aws_iam_user" "users" {
  for_each = toset(var.user_names)
  name     = each.key
}

resource "aws_iam_user_login_profile" "login_profile" {
  for_each                = toset(var.user_names)   # Change this to var.iam_users to match the variable definition
  user                    = aws_iam_user.users[each.key].name  # Reference the user name correctly
  password_reset_required = true  # Users will need to reset their passwords on first login
}


# Create Access Keys for Each User (for API/CLI access)
resource "aws_iam_access_key" "user_access_key" {
  for_each = aws_iam_user.users
  user     = each.key
}

# Attach policies to each IAM user
resource "aws_iam_user_policy_attachment" "full_access_policy" {
  for_each   = var.user_policies
  user       = aws_iam_user.users[each.key].name
  policy_arn = each.value  # This should be a string

}

