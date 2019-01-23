// Create S3 bucket and CloudFront distribution using Terraform module designed for S3/CloudFront
// configuration of a Hugo site. See: https://registry.terraform.io/modules/fillup/hugo-s3-cloudfront/aws/1.0.2
module "staticsite" {
  source                 = "fillup/hugo-s3-cloudfront/aws"
  version                = "2.0.0"
  aliases                = ["${var.aliases}"]
  aws_region             = "${var.aws_region}"
  bucket_name            = "${var.bucket_name}"
  origin_path            = ""
  cert_domain            = "${var.cert_domain_name}"
  cf_default_ttl         = "0"
  cf_max_ttl             = "0"
  viewer_protocol_policy = "allow-all"
  cors_allowed_origins   = ["https://${var.subdomain}.${var.cloudflare_domain}", "http://${var.subdomain}.${var.cloudflare_domain}"]
}

data "template_file" "user_bucket_policy" {
  template = "${file("${path.module}/user-bucket-policy.json")}"

  vars {
    bucket_name = "${var.bucket_name}"
  }
}

resource "aws_iam_user" "upload_user" {
  name = "${var.upload_user_username}-${var.app_env}"
}

resource "aws_iam_access_key" "upload_user" {
  user = "${aws_iam_user.upload_user.name}"
}

resource "aws_iam_user_policy" "upload_user" {
  policy = "${data.template_file.user_bucket_policy.rendered}"
  user   = "${aws_iam_user.upload_user.name}"
}

data "template_file" "debian_index" {
  template = "${file("${path.module}/index.html")}"

  vars {
    bucket_url         = "https://${var.bucket_name}.s3.amazonaws.com"
    bucket_website_url = "https://${var.subdomain}.${var.cloudflare_domain}"
    root_dir           = "debian/"
    aws_region         = "${var.aws_region}"
  }
}

resource "aws_s3_bucket_object" "debian_index" {
  bucket       = "${var.bucket_name}"
  key          = "debian/index.html"
  acl          = "public-read"
  content_type = "text/html;charset=UTF-8"
  content      = "${data.template_file.debian_index.rendered}"
}

data "template_file" "ubuntu_index" {
  template = "${file("${path.module}/index.html")}"

  vars {
    bucket_url         = "https://${var.bucket_name}.s3.amazonaws.com"
    bucket_website_url = "https://${var.subdomain}.${var.cloudflare_domain}"
    root_dir           = "ubuntu/"
    aws_region         = "${var.aws_region}"
  }
}

resource "aws_s3_bucket_object" "ubuntu_index" {
  bucket       = "${var.bucket_name}"
  key          = "ubuntu/index.html"
  acl          = "public-read"
  content_type = "text/html;charset=UTF-8"
  content      = "${data.template_file.ubuntu_index.rendered}"
}

resource "aws_s3_bucket_object" "listjs" {
  bucket       = "${var.bucket_name}"
  key          = "list.js"
  acl          = "public-read"
  content_type = "application/javascript"
  source       = "${path.module}/list.js"
}

// Create DNS CNAME record on Cloudflare
resource "cloudflare_record" "packages" {
  domain     = "${var.cloudflare_domain}"
  name       = "${var.subdomain}"
  type       = "CNAME"
  value      = "${module.staticsite.cloudfront_hostname}"
  proxied    = true
  depends_on = ["module.staticsite"]
}
