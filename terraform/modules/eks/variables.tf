variable "cluster_name" {
  default = "devops-eks"
}

variable "private_subnet_ids" {
  type = list(string)
}