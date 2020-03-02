locals {
  ubdomain = "unbearablecomics.com"
}

resource "cloudflare_zone" "unbearablecomics" {
  zone = "unbearablecomics.com"
}

resource "cloudflare_record" "unbearablecomics-cname-apex" {
  name    = local.ubdomain
  zone_id = cloudflare_zone.unbearablecomics.id
  value   = "www.unbearablecomics.com.s3-website-us-west-2.amazonaws.com"
  type    = "CNAME"
  ttl     = "1"
  proxied = true
}

resource "cloudflare_record" "unbearablecomics-www-cname" {
  zone_id = cloudflare_zone.unbearablecomics.id
  value   = "www.unbearablecomics.com.s3-website-us-west-2.amazonaws.com"
  name    = "www"
  type    = "CNAME"
  ttl     = "1"
  proxied = true
}

resource "aws_s3_bucket" "unbearable-bucket-site" {
  bucket = "www.unbearablecomics.com"
  acl    = "public-read"

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
}

resource "cloudflare_zone_settings_override" "ub_settings" {
  zone_id = cloudflare_zone.unbearablecomics.id
  settings {
    always_use_https = "on"
  }
}

resource "cloudflare_page_rule" "ub_redirect_non_www" {
  zone_id  = cloudflare_zone.unbearablecomics.id
  target   = "${local.ubdomain}/*"
  priority = 1

  actions {
    forwarding_url {
      url          = "https://www.${local.ubdomain}/$1"
      status_code  = 301
    }
  }
}
