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