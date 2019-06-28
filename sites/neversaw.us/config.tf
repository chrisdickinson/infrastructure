variable "ttl" {
  default = 30
}

variable "env_site_access_key" {
}

variable "env_site_secret_key" {
}

provider "cloudflare" {
  use_org_from_zone = "neversaw.us"
}

provider "aws" {
  region = "us-west-2"
}

