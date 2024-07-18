resource "aws_vpc" "test-tf-vpc" {
  cidr_block = "10.0.0.0/16"
  enable_dns_hostnames = true
  enable_dns_support = true
  tags = {
    Name = "test-vpc"
  }
}

resource "aws_subnet" "public-subnet" {
    vpc_id = aws_vpc.test-tf-vpc.id
    cidr_block = "10.0.1.0/24"
    map_public_ip_on_launch = true
    tags = {
        Name = "public-subnet-test"
    }
}

resource "aws_security_group" "securityGroup" {
  vpc_id = aws_vpc.test-tf-vpc.id
  name = "Test-SG"
  description = "Allows 22 only from internet"
  ingress  {
    from_port = 22
    to_port = 22
    protocol = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port = 0 
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

