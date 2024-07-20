terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.58.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

locals {
  project = "AI"
}

# locals {
#   ubuntu_ami = "ami-0ad21ae1d0696ad58"
#   amazon_ami = "ami-0ec0e125bb6c6e8ec"
# }

# Create vpc
resource "aws_vpc" "main" {
    cidr_block = "10.0.0.0/16"
    tags = {
      name = "${local.project}-vpc"
      Name = "${local.project}-vpc"
    }
}


# Create 2 subnets using count
resource "aws_subnet" "new-sub" {
    vpc_id = aws_vpc.main.id
    cidr_block = "10.0.${count.index}.0/24"
    count = 2
    tags = {
      name = "${local.project}-subnet-${count.index}"
      Name = "${local.project}-subnet-${count.index}"
    }
}

# Create Ec2 instances with count meta argument
# resource "aws_instance" "name" {
#     count = length(var.ec2)
#     ami = var.ec2[count.index].ami
#     instance_type = var.ec2[count.index].instance_type

#     subnet_id = element(aws_subnet.new-sub[*].id, count.index % length(aws_subnet.new-sub))
#     tags = {
#     Name = "${local.project}-${count.index+1}"
#   }
# }

# output "subnet" {
#     value = aws_subnet.new-sub[0].id
# }

## for-each meta arguments
## Used in map & set of strings
## Map of objects

## Creating ec2 using for-each meta argument
resource "aws_instance" "web-server" {
  # get the for-each called to create resource 
  for_each = var.ec2-type
  // Here we will get each.key & each.value from the above for-each
  ## each.key will return "ubuntu" & "amazon_linux"
  ## each.value will return ami & instance type both with in another object {}
  ami = each.value.ami
  instance_type = each.value.instance_type

  # subnet_id = element(aws_subnet.new-sub[*].id, index(keys(var.ec2-type), each.key) % length(aws_subnet.new-sub))
  subnet_id = element(aws_subnet.new-sub[*].id, index(keys(var.ec2-type), each.key) % length(aws_subnet.new-sub))
  tags = {
    Name = "${local.project}-instance-${each.key}"
  }
}