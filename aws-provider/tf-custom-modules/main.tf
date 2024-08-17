module "network" {
  source = "./modules/network"
  # vpc_cidr = "10.0.0.0/16"
  # vpc_Name = "new-test-vpc"
  # public_subnet_cidr = "10.0.1.0/24"
}

module "server" {
  source = "./modules/compute"
  pub_sub_id = module.network.pub_sub_id
}