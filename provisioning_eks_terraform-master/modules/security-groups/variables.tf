variable "vpc_id" {
  description = "The ID of the VPC that the security group will be placed"
  type        = string
}

variable "cluster_name" {
  description = "The name of your EKS Cluster"
  type        = string
  default     = "eks-cluster"
}
