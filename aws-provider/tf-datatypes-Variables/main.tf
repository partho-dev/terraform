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
  name = "tag-1"
  volume_size = 30
}

resource "aws_instance" "server" {
    ami = "ami-0ad21ae1d0696ad58"
    instance_type = var.instance_type

    root_block_device {
      delete_on_termination = true
      volume_size = local.volume_size // get from the local variabl
      volume_type = var.define-volume.volume_type // get from the variabl
    }

    tags = {
      name = local.name
    }
}

