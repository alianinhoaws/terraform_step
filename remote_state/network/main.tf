provider "aws" {
  region = "eu-north-1"
}

terraform {
  backend "s3" {
    bucket = "terraform-step-academy1"
    key = "dev/classes/networking" #file
    region = "eu-north-1"
  }
}

data "aws_availability_zones" "available_zones" {}


variable "vpc_cird" {
  default = "10.0.0.0/16"
}

variable "public_subnet" {
  default = "10.0.10.0/24"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cird
  tags = {
    Name = "Web-VPC"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "Web"
  }
}

resource "aws_subnet" "public_subnet" {
  cidr_block = var.vpc_cird
  vpc_id = aws_vpc.main.id
  availability_zone = data.aws_availability_zones.available_zones.names[0]
  map_public_ip_on_launch = true
  tags = {
    Name = "Web"
  }
}

resource "aws_route_table" "public_routes" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "Web"
  }
}

resource "aws_route_table_association" "public_route" {
  route_table_id = aws_route_table.public_routes.id
  subnet_id = aws_subnet.public_subnet.id
}

output "vpc_id" {
  value = aws_vpc.main.id
}

output "subnet_id" {
  value = aws_subnet.public_subnet.id
}