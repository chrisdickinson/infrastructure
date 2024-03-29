locals {
  environment = terraform.workspace
  config_cluster_key = "consul-${terraform.workspace}"
  config_cluster_value = "yes"
}

variable "github_token" {
  type = string
}
