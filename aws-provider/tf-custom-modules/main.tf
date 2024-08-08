terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.61.0"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-south-1"
}


variable "subnet_config" {
    description = "This has all about the subscriptions properties"

type = map(object({
  cidr = list(string)
  az = list(string)
  is_public = bool  
}))

default = {
  "public" = {
    cidr = ["10.0.1.0/24", "10.0.3.0/24"]
    az = ["ap-south-1a"]
    is_public = true
  }

  "private" = {
    cidr = ["10.0.2.0/24", "10.0.4.0/24"]
    az = ["ap-south-1b"]
    is_public = false
  }
}
}

# locals {

# }

output "local_out" {
    value = var.subnet_config
}