module "vpc" {
  source = "./modules/vpc"
}

module "eks" {

  source = "./modules/eks"

  private_subnet_ids = module.vpc.private_subnet_ids
}