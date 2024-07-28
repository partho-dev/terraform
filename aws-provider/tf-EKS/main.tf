module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.9.0"

  name = "EKS-VPC"
  cidr = var.vpc_cidr[0]


  azs             = data.aws_availability_zones.az.names
  private_subnets = var.priv_sub[*]
  public_subnets  = var.pub_sub[*]

  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true

  tags = {
    Terraform                           = "true"
    Environment                         = "dev"
    "kubernetes.io/cluster/Web-Cluster" = "shared"
  }

  public_subnet_tags = {
    "kubernetes.io/cluster/Web-Cluster" = "shared"
    "kubernetes.io/role/elb"            = 1
  }

  private_subnet_tags = {
    "kubernetes.io/cluster/Web-Cluster" = "shared"
    "kubernetes.io/role/internal-elb"   = 1
  }

}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "20.20.0"

  cluster_name    = "Web-Cluster"
  cluster_version = "1.30"

  cluster_endpoint_public_access = true
  cluster_security_group_id = module.vpc.default_security_group_id


  vpc_id     = module.vpc.default_vpc_id
  subnet_ids = module.vpc.private_subnets
  #   control_plane_subnet_ids = ["subnet-xyzde987", "subnet-slkjf456", "subnet-qeiru789"]

  # EKS Managed Node Group(s)
  #   eks_managed_node_group_defaults = {
  #     instance_types = ["m6i.large", "m5.large", "m5n.large", "m5zn.large"]
  #   }

  eks_managed_node_groups = {
    web_nodes = {
      # Starting on 1.30, AL2023 is the default AMI type for EKS managed node groups
      #   ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t2.small"]

      min_size     = 1
      max_size     = 2
      desired_size = 1
    }
  }

  # Cluster access entry
  #   # To add the current caller identity as an administrator
  #   enable_cluster_creator_admin_permissions = true

  #   access_entries = {
  #     # One access entry with a policy associated
  #     example = {
  #       kubernetes_groups = []
  #       principal_arn     = "arn:aws:iam::123456789012:role/something"

  #       policy_associations = {
  #         example = {
  #           policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"
  #           access_scope = {
  #             namespaces = ["default"]
  #             type       = "namespace"
  #           }
  #         }
  #       }
  #     }
  #   }

  tags = {
    Environment = "dev"
    Terraform   = "true"
  }

}