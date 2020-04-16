variable "aws_region" {
  description = "The AWS region"
  type        = string
  default     = "eu-west-2"
}

variable "cluster_name" {
  description = "The name of your EKS Cluster"
  type        = string
  default     = "eks-cluster"
}

variable "kubernetes_version" {
  description = "The version of Kubernetes that you wish to run"
  type        = string
  default     = "1.15"
}

variable "cluster_security_group_ids" {
  description = "Security groups to apply to the EKS-managed Elastic Network Interfaces that are created in your worker node subnets."
  type        = list(string)
}

variable "node_security_group_ids" {
  description = "Security groups to apply to the EKS nodes"
  type        = list(string)
}

variable "private_subnet_ids" {
  description = "Subnet IDs for the worker nodes"
  type        = list(string)
}

variable "eks_cw_logging" {
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
  type        = list
  description = "Enable EKS CWL for EKS components"
}

variable "node_instance_type" {
  description = "The AWS instance size for your EKS nodes"
  type        = string
  default     = "m4.large"

}

