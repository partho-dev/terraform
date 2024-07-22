terraform {
  backend "s3" {
    bucket         = "partho-state-bkt"
    key            = "partho_backup.tfstate"
    region         = "ap-south-1"
    dynamodb_table = "db-locks-table"
  }
  # required_providers {
  #   aws = {
  #     source  = "hashicorp/aws"
  #     version = "~> 5.0"
  #   }
  # }
}

provider "aws" {
  region = "ap-south-1"
}


resource "aws_instance" "webserver" {
  ami           = "ami-0ad21ae1d0696ad58"
  instance_type = "t2.micro"
  tags = {
    Name = "tf-example"
  }
}

output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_instance.webserver.public_ip
}