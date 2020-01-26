variable "cluster_name" {}
variable "vpc_id" {}
variable "subnet_ids" {
  type = "list"
}
variable "instance_types" {}

variable "desired_capacity" {}

variable "max_size" {}

variable "min_size" {}

variable "eks-version" {}

variable "number_of_node_groups" {}
