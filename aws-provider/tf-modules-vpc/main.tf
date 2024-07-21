terraform {
  
}
provider "aws" {
  region = "ap-south-1"
}

# data "aws_availability_zone" "name" {
#     state = "available"
# }

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "5.9.0"

#   name = "my-vpc"
#   cidr = "10.0.0.0/16"

#   azs = data.aws_availability_zone.name.names
#   public_subnets = [ "10.0.1.0/24" ]
#   private_subnets = ["10.0.2.0/24"]

# }

variable "servers" {
  type = map(string)
  default = {
    server1 = "10.0.0.1"
    server2 = "10.0.0.2"
    server3 = "10.0.0.3"
  }
}

locals {
  server_descriptions = { for key, value in var.servers : key => "serverIP-${value}" }
}

output "server_descriptions" {
  value = local.server_descriptions
}