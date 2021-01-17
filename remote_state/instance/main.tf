provider "aws" {
  region = "eu-north-1"
}

terraform {
  backend "s3" {
    bucket = "terraform-step-academy1"
    key = "dev/classes/instances" #file
    region = "eu-north-1"
  }
}

data "aws_ami" "amzon_linux" {
  owners = ["amazon"]
  most_recent = true
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}

data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "terraform-step-academy1"
    key = "dev/classes/networking" #file
    region = "eu-north-1"
  }
}

resource "aws_instance" "web_server" {
  ami = data.aws_ami.amzon_linux.id
  instance_type = "t3.micro"
  vpc_security_group_ids = [aws_security_group.web_server.id]
  subnet_id = data.terraform_remote_state.network.outputs.subnet_id
  user_data = templatefile("script.sh.tpl",
  {
    f_name = "Andrii"
    l_name = "Maz"
    names = ["Anna", "Lena"]
  })
}

variable "ports" {
  default = ["80","443"]
}

resource "aws_security_group" "web_server" {
  name_prefix = "Web"
  vpc_id = data.terraform_remote_state.network.outputs.vpc_id
  tags = {
    Name = "Web"
  }
  dynamic "ingress" {
    for_each = var.ports
    content {
      from_port = ingress.value #80 #443
      to_port = ingress.value #80  #443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }
  egress {
    from_port = 0
    protocol = "-1"
    to_port = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

output "instance_ip" {
  value = aws_instance.web_server.public_ip
}