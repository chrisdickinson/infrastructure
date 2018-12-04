variable domain {
  default = "neversaw.us"
}

resource "cloudflare_zone" "neversawus" {
  zone = "${var.domain}"
}

resource "cloudflare_record" "neversawus-apex" {
  domain  = "${var.domain}"
  name    = "${var.domain}"
  value   = "192.241.193.154"
  type    = "A"
  ttl     = "1"
  proxied = true
}

resource "cloudflare_record" "neversawus-www-cname" {
  domain  = "${var.domain}"
  value   = "www.neversaw.us.s3-website-us-west-2.amazonaws.com"
  name    = "www"
  type    = "CNAME"
  ttl     = "1"
  proxied = true
}

resource "cloudflare_record" "neversawus-static-cname" {
  domain  = "${var.domain}"
  value   = "${var.domain}"
  name    = "static"
  type    = "CNAME"
  ttl     = "1"
  proxied = true
}

resource "cloudflare_record" "neversawus-mx-0" {
  domain   = "${var.domain}"
  name     = "${var.domain}"
  value    = "aspmx3.googlemail.com"
  priority = 10
  type     = "MX"
}

resource "cloudflare_record" "neversawus-mx-1" {
  domain   = "${var.domain}"
  name     = "${var.domain}"
  value    = "aspmx.l.google.com"
  priority = 1
  type     = "MX"
}

resource "cloudflare_record" "neversawus-mx-2" {
  domain   = "${var.domain}"
  name     = "${var.domain}"
  value    = "aspmx2.googlemail.com"
  priority = 10
  type     = "MX"
}

resource "cloudflare_record" "neversawus-mx-3" {
  domain   = "${var.domain}"
  name     = "${var.domain}"
  value    = "alt2.aspmx.l.google.com"
  priority = 5
  type     = "MX"
}

resource "cloudflare_record" "neversawus-mx-4" {
  domain   = "${var.domain}"
  name     = "${var.domain}"
  value    = "alt1.aspmx.l.google.com"
  priority = 5
  type     = "MX"
}

resource "aws_s3_bucket" "bucket-site" {
  bucket = "www.neversaw.us"
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
