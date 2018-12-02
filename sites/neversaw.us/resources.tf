resource "cloudflare_record" "neversawus-apex" {
  domain  = "neversaw.us"
  name    = "neversaw.us"
  value   = "192.241.193.154"
  type    = "A"
  ttl     = "1"
  proxied = true
}

resource "cloudflare_record" "neversawus-www-cname" {
  domain  = "neversaw.us"
  value   = "neversaw.us"
  name    = "www"
  type    = "CNAME"
  ttl     = "1"
  proxied = true
}

resource "cloudflare_record" "neversawus-static-cname" {
  domain  = "neversaw.us"
  value   = "neversaw.us"
  name    = "static"
  type    = "CNAME"
  ttl     = "1"
  proxied = true
}
