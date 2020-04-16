variable "cluster_name" {
  description = "The name of your EKS Cluster"
  type        = string
  default     = "eks-cluster"
}

variable "eks_public_subnet_ids" {
  description = "The IDs of public subnets"
  type        = list(string)
}

variable "bastion_security_group_ids" {
  description = "Security group IDs for the bastions"
  type        = list(string)
}

variable "ec2_key_public_key" {
  description = "The public SSH key you generated"
  type        = string
}



