module "eks" {
  source          = "./modules/eks/"
  cluster_name    = "jcd"
  eks-version     = "1.14"
  number_of_node_groups = 2
  vpc_id          = "vpc-6b5bfd11"
  subnet_ids      = ["subnet-16cb5d4a", "subnet-260b4429", "subnet-3b547171"]
  instance_types  = "t3.medium"
  desired_capacity = "4"
  max_size         = "10"
  min_size         = "4"
}