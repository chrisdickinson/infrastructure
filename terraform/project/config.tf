terraform {
  backend "s3" {
    bucket       = "neversawus-terraform"
    key          = "services.tfstate"
    region       = "us-west-2"
    session_name = "terraform"
  }
}

variable "ttl" {
  default = 30
}

variable "site_access_key" {
}

variable "site_secret_key" {
}

provider "cloudflare" {
}

provider "aws" {
  region = "us-west-2"
}

data "aws_ami" "consul" {
  most_recent = true
  owners      = ["self"]

  filter {
    name   = "name"
    values = ["consul-ubuntu-*"]
  }

  filter {
    name   = "tag:Qualified"
    values = ["true"]
  }
}

/*
module "consul" {
  source = "github.com/hashicorp/terraform-aws-consul//modules/consul-cluster?ref=v0.7.4"

  ami_id = data.aws_ami.consul.id

  cluster_tag_key   = local.config_cluster_key
  cluster_tag_value = local.config_cluster_value

  user_data = <<-EOF
              #!/bin/bash
              /opt/consul/bin/run-consul --server --cluster-tag-key ${local.config_cluster_key} --cluster-tag-value ${local.config_cluster_value}
              EOF

  subnet_ids = aws_subnet.private[*].id

  cluster_name                       = "configuration"
  instance_type                      = "t2.nano"
  vpc_id                             = aws_vpc.main.id
  ssh_key_name                       = aws_key_pair.admin.key_name
  allowed_inbound_cidr_blocks        = ["10.0.0.0/8"]
  allowed_inbound_security_group_ids = [aws_security_group.configurable.id]
  additional_security_group_ids = [
    aws_security_group.allow-ssh.id
  ]
}
*/
