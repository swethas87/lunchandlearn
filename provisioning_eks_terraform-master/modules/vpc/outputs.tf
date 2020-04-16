output "eks_vpc_id" {
  value = aws_vpc.eks-vpc.id
}

output "eks_public_subnet_ids" {
  description = "List of IDs of public subnets"
  value       = aws_subnet.eks-vpc-public-subnet.*.id
}

output "eks_private_subnet_ids" {
  description = "List of IDs of private subnets"
  value       = aws_subnet.eks-vpc-private-subnet.*.id
}



