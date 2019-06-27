resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  tags = {
    "Name" = "default"
  }
}

resource "aws_subnet" "main" {
  cidr_block = "10.0.0.0/18"
  vpc_id     = aws_vpc.main.id
  tags = {
    "Name" = "Public subnet"
  }
}

resource "aws_instance" "irc" {
  ami = "ami-09bfeda7337019518"

  subnet_id         = aws_subnet.main.id
  availability_zone = "us-west-2a"
  ebs_optimized     = true
  instance_type     = "t3.nano"
  monitoring        = false
  key_name          = "chris-personal-west.pem"

  associate_public_ip_address = true

  tags = {
    "Name" = "neversawus-znc"
  }
}

