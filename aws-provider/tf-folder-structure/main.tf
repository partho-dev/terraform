# Call both the child modules on parent main.tf file 

module "vpc-module" {
    source = "./vpc-module"
  
}

module "ec2-module" {
    source = "./Ec2-module"
    publicSubnet = module.vpc-module.publicSubnet
    sg = module.vpc-module.sg
}