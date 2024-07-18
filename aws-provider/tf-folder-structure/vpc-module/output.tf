## output.tf of VPC module, getting the output of its main.tf 

output "vpc-id" {
  value = aws_vpc.test-tf-vpc.id
}

output "sg" {
  value = aws_security_group.securityGroup.id
}

output "publicSubnet" {
  value = aws_subnet.public-subnet.id
}