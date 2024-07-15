terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.58.0"
    }
    random = {
      source = "hashicorp/random"
      version = "3.6.2"
    }
  }
}

provider "aws" {
  # Configuration options
  region = "ap-south-1"
}

resource "aws_vpc" "vpc-tf" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name="tf"
  }
}

resource "aws_internet_gateway" "tf-ig" {
  vpc_id = aws_vpc.vpc-tf.id
}

resource "aws_subnet" "tf-public" {
  vpc_id = aws_vpc.vpc-tf.id
  cidr_block = "10.0.1.0/24"
  availability_zone = "ap-south-1a"
  tags = {
    Name="tf-public-subnet"
  }
}

resource "aws_subnet" "tf-private" {
  vpc_id = aws_vpc.vpc-tf.id
  cidr_block = "10.0.2.0/24"
  availability_zone = "ap-south-1b"
  tags = {
    Name="tf-private-subnet"
  }
}

resource "aws_route_table" "tf-public-rt" {
  vpc_id = aws_vpc.vpc-tf.id

  route {
    cidr_block="0.0.0.0/0"
    gateway_id = aws_internet_gateway.tf-ig.id
  }
  
  tags = {
    Name="tf-public-rt"
  }
}

resource "aws_route_table" "tf-private-rt" {
  vpc_id = aws_vpc.vpc-tf.id
  # Local Route is automatically created by AWS
  # route {
  #   cidr_block = "10.0.0.0/16"
  #   gateway_id = "local"
  # }
  tags = {
    Name="tf-private-rt"
  }
}

##Associate the RT with subnet
resource "aws_route_table_association" "tf-rt-public" {
  subnet_id = aws_subnet.tf-public.id
  route_table_id = aws_route_table.tf-public-rt.id 
}

resource "aws_route_table_association" "tf-rt-private" {
  subnet_id = aws_subnet.tf-private.id
  route_table_id = aws_route_table.tf-private-rt.id 
}
