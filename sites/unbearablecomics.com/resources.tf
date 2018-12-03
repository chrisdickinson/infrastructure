variable domain {
  default = "unbearablecomics.com"
}
resource "cloudflare_record" "unbearablecomics-apex" {
  domain  = "${var.domain}"
  name    = "${var.domain}"
  value   = "192.241.193.154"
  type    = "A"
  ttl     = "1"
  proxied = true
}

resource "cloudflare_record" "unbearablecomics-www-cname" {
  domain  = "${var.domain}"
  value   = "${var.domain}"
  name    = "www"
  type    = "CNAME"
  ttl     = "1"
  proxied = true
}

resource "aws_s3_bucket" "bucket-site" {
  bucket = "unbearablecomics-site"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}
