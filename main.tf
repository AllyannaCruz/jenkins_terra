terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
# Configure the AWS Provider
provider "aws" {
  region = "us-east-2"
}
data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_instance" "instance" {
    # from data "aws_ami" "ubuntu" 
    ami = data.aws_ami.ubuntu.id
    instance_type = "t3.micro"
    key_name="user1_deployer-key"
    count=3 #1
    tags = {
        Name="user-instance-${count.index}"
        role=count.index==0?"user1-lb": (count.index<4?"user1-web":"user1-backend")
    }
}

output "ips" {
        value = aws_instance.instance.*.public_ip
    }
