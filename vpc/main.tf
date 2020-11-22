resource "aws_vpc" "this" {
  cidr_block = "10.1.0.0/16"

  tags = {
    Name = "load-test-ecs"
  }
}

locals {
  public_subnets = [
    { availability_zone = "ap-northeast-1a", cidr_block = "10.1.0.0/24" },
    { availability_zone = "ap-northeast-1c", cidr_block = "10.1.1.0/24" },
  ]
}

resource "aws_subnet" "public" {
  count = 2
  vpc_id = aws_vpc.this.id
  availability_zone = local.public_subnets[count.index].availability_zone
  cidr_block = local.public_subnets[count.index].cidr_block
  map_public_ip_on_launch = true

  tags = {
    Name = "load-test-ecs-public-${count.index}"
  }
}

resource "aws_internet_gateway" "this" {
  vpc_id = aws_vpc.this.id

  tags = {
    Name = "load-test-ecs-igw"
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.this.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.this.id
  }

  tags = {
    Name = "public"
  }
}

resource "aws_main_route_table_association" "this" {
  vpc_id = aws_vpc.this.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_a" {
  count = 2
  subnet_id = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}
