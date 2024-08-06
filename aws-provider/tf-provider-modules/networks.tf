
locals {
  name = "partho"
  vpc_cidr = "10.0.0.0/16"
}
data "aws_availability_zones" "name" {
    state = "available"
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.9.0"

  name = "${local.name}-vpc"
  cidr = "${local.vpc_cidr}"

  azs = data.aws_availability_zones.name.names
  public_subnets = ["10.0.1.0/24"]
  private_subnets = ["10.0.2.0/24"]

tags = {
  Name = "${local.name}-vpc"
}
public_subnet_tags = {Name = "${local.name}-pub-sub"}
private_subnet_tags = {Name = "${local.name}-priv-sub"}

public_route_table_tags =  {Name = "${local.name}-pub-rt"}
private_route_table_tags = {Name = "${local.name}-priv-rt"}


}

output "azs" {
    value = module.vpc.azs
}