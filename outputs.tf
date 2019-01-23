output "s3_bucket" {
  value = "${var.bucket_name}"
}

output "upload_user_access_key" {
  value = "${aws_iam_access_key.upload_user.id}"
}

output "upload_user_secret_key" {
  value = "${aws_iam_access_key.upload_user.secret}"
}

output "upload_user_username" {
  value = "${aws_iam_user.upload_user.name}"
}

output "url" {
  value = "${var.subdomain}.${var.cloudflare_domain}"
}
