variable "aliases" {
  type        = "list"
  description = "List of domains for serving site"
}

variable "app_env" {
  type = "string"
}

variable "aws_region" {
  default = "us-east-1"
}

variable "aws_access_key" {}
variable "aws_secret_key" {}

variable "bucket_name" {
  type        = "string"
  description = "Name for S3 bucket, must be globally unique"
}

variable "cert_domain_name" {
  type        = "string"
  description = "Name on certificate to use for SSL"
}

variable "cloudflare_email" {}
variable "cloudflare_token" {}
variable "cloudflare_domain" {}

variable "origin_path" {
  default = ""
}

variable "subdomain" {
  default = "packages"
}

variable "upload_user_username" {
  default = "packages-uploader"
}
