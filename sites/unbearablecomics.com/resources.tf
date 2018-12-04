variable domain {
  default = "unbearablecomics.com"
}

resource "cloudflare_zone" "unbearablecomics" {
  zone = "${var.domain}"
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
  value   = "www.unbearablecomics.com.s3-website-us-west-2.amazonaws.com"
  name    = "www"
  type    = "CNAME"
  ttl     = "1"
  proxied = true
}

resource "aws_s3_bucket" "bucket-site" {
  bucket = "www.unbearablecomics.com"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "cloudflare_zone_settings_override" "settings" {
  name = "${var.domain}"
  settings {
    always_use_https = "on"
  }
}

resource "cloudflare_page_rule" "redirect_non_www" {
  zone     = "${var.domain}"
  target   = "${var.domain}/*"
  priority = 1

  actions = {
    forwarding_url = {
      url          = "https://www.${var.domain}/$1"
      status_code  = 301
    }
  }
}
