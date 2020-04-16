variable "cluster_name" {
  description = "The name of your EKS Cluster"
  type        = string
  default     = "eks-cluster"
}

variable "vpc_name" {
  description = "The name of your VPC"
  type        = string
}

variable "cidr_block" {
  description = "The CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zone_names" {
  type    = list(string)
  default = ["eu-west-2a", "eu-west-2b"]
}

variable "private_subnet_ranges" {
  description = "The CIDR ranges for your private subnets - there should be the same number as availability zones"
  type        = list(string)
  default     = ["10.0.0.0/19", "10.0.32.0/19"]
}

variable "public_subnet_ranges" {
  description = "The CIDR ranges for your public subnets - there should be the same number as availability zones"
  type        = list(string)
  default     = ["10.0.128.0/20", "10.0.144.0/20"]
}

