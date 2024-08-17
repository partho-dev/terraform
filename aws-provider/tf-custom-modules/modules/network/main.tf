resource "aws_vpc" "main" {
    cidr_block = var.vpc_cidr
    tags = {
      Name = var.vpc_Name
    }
}

resource "aws_subnet" "main" {
    vpc_id = aws_vpc.main.id
    cidr_block = var.public_subnet_cidr
    availability_zone = "ap-south-1a"

    tags = {
      Name = "${var.vpc_Name}-subnet"
    }
}