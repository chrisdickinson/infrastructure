data "aws_availability_zones" "azs" {}
data "local_file" "admin-key" {
  filename = pathexpand("~/.ssh/id_rsa.pub")
}

resource "aws_key_pair" "admin" {
  key_name   = "admin-${local.environment}"
  public_key = data.local_file.admin-key.content
}

resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
  enable_classiclink = false
  tags = {
    Name = "default"
  }

  lifecycle {
    create_before_destroy = true
  }
}

/*
resource "aws_internet_gateway" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_eip" "nat" {
  vpc = true
  count = 1
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_nat_gateway" "nat" {
  allocation_id = element(aws_eip.nat.*.id, count.index)
  subnet_id = element(aws_subnet.public.*.id, count.index)
  count = 1
}

resource "aws_route" "nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat.*.id, count.index)
  count                  = length(aws_nat_gateway.nat)
}

resource "aws_route" "igw" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.public.id
}

resource "aws_subnet" "private" {
  count             = 3
  cidr_block        = "10.0.${count.index}.0/24"
  availability_zone = element(data.aws_availability_zones.azs.names, count.index)
  vpc_id            = aws_vpc.main.id

  tags = {
    Name = "Private subnet"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_subnet" "public" {
  count                   = 3
  cidr_block              = "10.0.${10 + count.index}.0/24"
  availability_zone       = element(data.aws_availability_zones.azs.names, count.index)
  vpc_id                  = aws_vpc.main.id
  map_public_ip_on_launch = true

  tags = {
    Name = "Public subnet"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id
}

resource "aws_route_table_association" "private" {
  count          = 3
  subnet_id      = element(aws_subnet.private.*.id, count.index)
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "public" {
  count          = 3
  subnet_id      = element(aws_subnet.public.*.id, count.index)
  route_table_id = aws_route_table.public.id
}

resource "aws_security_group" "allow-ssh" {
  name = "allow-ssh"
  vpc_id = aws_vpc.main.id
  ingress {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow-egress" {
  name = "allow-egress"
  vpc_id = aws_vpc.main.id
  egress {
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "configurable" {
  name = "configurable"
  vpc_id = aws_vpc.main.id
}

resource "aws_instance" "test" {
  ami = "ami-06586557165d235d4"
  key_name = aws_key_pair.admin.key_name
  instance_type = "t3.micro"
  associate_public_ip_address = true
  subnet_id = aws_subnet.public[0].id
  vpc_security_group_ids = [
    aws_security_group.allow-ssh.id,
    aws_security_group.allow-egress.id,
  ]
  availability_zone = data.aws_availability_zones.azs.names[0]
}

resource "aws_instance" "test2" {
  ami = "ami-06586557165d235d4"
  key_name = aws_key_pair.admin.key_name
  instance_type = "t3.micro"
  subnet_id = aws_subnet.private[0].id
  vpc_security_group_ids = [
    aws_security_group.allow-ssh.id,
    aws_security_group.allow-egress.id,
  ]
  availability_zone = data.aws_availability_zones.azs.names[0]
}
*/
