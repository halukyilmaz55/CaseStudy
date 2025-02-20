module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "19.13.1"

  cluster_name    = var.eks_name
  cluster_version = var.eks_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets
  cluster_endpoint_public_access = true

  eks_managed_node_group_defaults = {
    ami_type = "AL2_x86_64" #  x86_64 mimarili bir AMI  kullanıldı ARM64 olması için cunku kodlar da mac de ARM oalrak derlenmişti

  }

  eks_managed_node_groups = {
    one = {
      name = "node-group-1"

      instance_types = [var.machine_type]

      min_size     = 1
      max_size     = 2
      desired_size = 2
    }
  }
}