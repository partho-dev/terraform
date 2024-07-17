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
  region = "ap-south-1"
}

data "aws_security_group" "name" {
    id = "sg-4bdda035"
}

output "sg" {
    value = data.aws_security_group.name.name
  
}