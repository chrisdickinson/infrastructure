variable ttl {
  default = 30
}

provider "cloudflare" {
  use_org_from_zone = "unbearablecomics.com"
}

provider "aws" {
  region = "us-west-2"
}
