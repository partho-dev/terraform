locals {
  name = "partho"
  ami = "ami-068e0f1a600cd311c"
}

# vpc
resource "aws_vpc" "name" {
  cidr_block = "10.0.0.0/16"
  instance_tenancy = "default"
  tags = {
    Name = "${local.name}-vpc"
  }
}

resource "aws_subnet" "name" {
  vpc_id = aws_vpc.name.id
  count = 2
  cidr_block = "10.0.${count.index}.0/24"

  tags = {
    Name = "${local.name}-subnet-${count.index}"
  }
}

## Create 4 ec2 instances, 2 in one subnet and other 2 on 2nd subnet (we have only 2 subnets)
## using count 
# resource "aws_instance" "name" {
#   ami = local.ami
#   instance_type = "t2.small"
#   count = 4
#   subnet_id = element(aws_subnet.name[*].id, count.index%2)

#   tags = {
#     Name = "${local.name}-ec2-${count.index}"
#   }

# }

## Create 4 Ec2 using for-each
resource "aws_instance" "server" {
    for_each = var.ec2-map
    # Key = Value 
    # ubuntu = { ami = "ami-0ad21ae1d0696ad58" instance_type = "t2.micro" }
  ami = each.value.ami
  instance_type = each.value.instance_type

subnet_id = element(aws_subnet.name[*].id, index(keys(var.ec2-map), each.key ) % length(aws_subnet.name) )
# [{}, {}]

tags = {
  Name = "${local.name}-instance-${each.key}"
}
}

output "DoubleSubnet" {
  value = aws_subnet.name
}
output "ec2" {
    value = aws_instance.server
}