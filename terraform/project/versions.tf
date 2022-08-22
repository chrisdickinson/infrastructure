terraform {
  required_providers {
    archive = {
      source = "hashicorp/archive"
    }
    aws = {
      source = "hashicorp/aws"
    }
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    external = {
      source = "hashicorp/external"
    }
    github = {
      source = "integrations/github"
    }
    local = {
      source = "hashicorp/local"
    }
    null = {
      source = "hashicorp/null"
    }
  }
  required_version = ">= 0.13"
}

provider "github" {
  owner = "chrisdickinson"
}

provider "cloudflare" {
}

provider "aws" {
  region = "us-west-2"
}

