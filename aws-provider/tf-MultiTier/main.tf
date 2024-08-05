terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.61.0"
    }
  }
}

provider "aws" {
  region = "ap-south-1"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = {
    Name = "main-vpc"
  }
}



variable "av_zones" {
  type    = list(string)
  default = ["ap-south-1a", "ap-south-1b"]
}

variable "ami" {
    type = string
    default = "ami-0ad21ae1d0696ad58"
  
}

variable "cidrs_of_subnet" {
  description = "This will have the lists of CIDRs of different subnet types"
  type = map(object({
    is_public = bool
    CIDRS = list(string) 
  }))

  default = {
    "public-subnet" = {
        is_public=true
        CIDRS = ["10.0.2.0/24", "10.0.4.0/24"]
    }
    "private-subnet" = {
    is_public=false
    CIDRS = ["10.0.1.0/24", "10.0.3.0/24"]
    }
  }
}

locals {
  cidr_config = flatten([for subnet_type, subnet_object in var.cidrs_of_subnet : [for key, cidr in subnet_object.CIDRS :{
    cidr_of_subnet = cidr
    public = subnet_object.is_public
    name = "${subnet_type}-${key+1}" //subnet-public-subnet-1 subnet-public-subnet-2 subnet-private-subnet-1 subnet-private-subnet-2
  }]])
} 

output "cidr" {
    value = local.cidr_config
}

resource "aws_subnet" "main" {
    # for_each = local.cidr_config // We cant use this directly because for each needs map of set, but its a tuple
    /*
    variable "example_tuple" {
    type    = tuple([string, number, bool])
    default = ["apple", 42, true]
    }
    we need to comvert the tuple to map or set
    */
    for_each = {for subnet in local.cidr_config : "${subnet.cidr_of_subnet}" => subnet  }
    vpc_id = aws_vpc.main.id
    cidr_block = each.value.cidr_of_subnet
    availability_zone = element(var.av_zones[*], index(local.cidr_config, each.value) % length(var.av_zones) )
    map_public_ip_on_launch = each.value.public == true

    tags = {
      Name = "subnet-${each.value.name}"
    }
}

output "subnet" {
    value = aws_subnet.main
}

## Create Ec2 on public subnet & RDS on private
// We would need to get the subnet_id to refer while creating the ec2 and rds 


locals {
  public_subnet_ids = [ for k, v in aws_subnet.main : v.id if local.cidr_config[index(keys(aws_subnet.main), k)].public ]
  private_subnet_ids = [ for k, v in aws_subnet.main : v.id if !local.cidr_config[index(keys(aws_subnet.main), k)].public ]
}

output "public_subnet_ids" {
    value = local.public_subnet_ids
}

output "private_subnet_ids" {
    value = local.private_subnet_ids
}

## create EC2 on public subnet
resource "aws_instance" "main" {
    ami = var.ami
    instance_type = "t2.micro"
    subnet_id = element(local.public_subnet_ids[*], 0)

    tags = {
      Name = "web-server"
    }
}

// Create RDS in private subnet
# resource "aws_db_instance" "default" {
#   allocated_storage    = 10
#   db_name              = "mydb"
#   engine               = "mysql"
#   engine_version       = "8.0"
#   instance_class       = "db.t3.micro"
#   username             = "root"
#   password             = "mypassword"
#   parameter_group_name = "default.mysql8.0"
#   skip_final_snapshot  = true
# }

# resource "aws_db_subnet_group" "main" {
#   name       = "main-subnet-group"
#   subnet_ids = local.private_subnet_ids

#   tags = {
#     Name = "main-subnet-group"
#   }
# }
