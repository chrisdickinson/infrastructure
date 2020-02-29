variable "domain" {
  default = "neversaw.us"
}

resource "cloudflare_zone" "neversawus" {
  zone = var.domain
}

# zone-wide settings.
resource "cloudflare_zone_settings_override" "settings" {
  zone_id = cloudflare_zone.neversawus.id
  settings {
    always_use_https = "on"
  }
}

resource "cloudflare_record" "neversawus-cname-apex" {
  name    = var.domain
  zone_id = cloudflare_zone.neversawus.id
  value   = "www.neversaw.us.s3-website-us-west-2.amazonaws.com"
  type    = "CNAME"
  ttl     = "1"
  proxied = true
}

resource "cloudflare_record" "neversawus-www-cname" {
  zone_id = cloudflare_zone.neversawus.id
  value   = "www.neversaw.us.s3-website-us-west-2.amazonaws.com"
  name    = "www"
  type    = "CNAME"
  ttl     = "1"
  proxied = true
}

resource "cloudflare_record" "neversawus-static-cname" {
  zone_id = cloudflare_zone.neversawus.id
  value   = var.domain
  name    = "static"
  type    = "CNAME"
  ttl     = "1"
  proxied = true
}

resource "cloudflare_record" "neversawus-mx-0" {
  zone_id  = cloudflare_zone.neversawus.id
  name     = var.domain
  value    = "aspmx3.googlemail.com"
  priority = 10
  type     = "MX"
}

resource "cloudflare_record" "neversawus-mx-1" {
  zone_id  = cloudflare_zone.neversawus.id
  name     = var.domain
  value    = "aspmx.l.google.com"
  priority = 1
  type     = "MX"
}

resource "cloudflare_record" "neversawus-mx-2" {
  zone_id  = cloudflare_zone.neversawus.id
  name     = var.domain
  value    = "aspmx2.googlemail.com"
  priority = 10
  type     = "MX"
}

resource "cloudflare_record" "neversawus-mx-3" {
  zone_id  = cloudflare_zone.neversawus.id
  name     = var.domain
  value    = "alt2.aspmx.l.google.com"
  priority = 5
  type     = "MX"
}

resource "cloudflare_record" "neversawus-mx-4" {
  zone_id  = cloudflare_zone.neversawus.id
  name     = var.domain
  value    = "alt1.aspmx.l.google.com"
  priority = 5
  type     = "MX"
}

resource "cloudflare_page_rule" "redirect_non_www" {
  zone_id  = cloudflare_zone.neversawus.id
  target   = "${var.domain}/*"
  priority = 1

  actions {
    forwarding_url {
      url         = "https://www.${var.domain}/$1"
      status_code = 301
    }
  }
}

