variable ttl {
  default = 30
}

provider "cloudflare" {
  use_org_from_zone = "neversaw.us"
}

provider "aws" {
  region = "us-west-2"
}
