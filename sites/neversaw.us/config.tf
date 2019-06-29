variable "ttl" {
  default = 30
}

variable "site_access_key" {
}

variable "site_secret_key" {
}

provider "cloudflare" {
  use_org_from_zone = "neversaw.us"
}

provider "aws" {
  region = "us-west-2"
}

