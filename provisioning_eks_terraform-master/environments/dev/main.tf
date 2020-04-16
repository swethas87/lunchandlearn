provider "aws" {
    # This profile maps to the profile name defined in your ~/.aws/credentials
    profile    = "terraform"

    # The default AWS region
    region     = var.region

    # Minimum version for the AWS provider
    version     = "~> 2.56"
}

provider "http" {

    # Minimum version for the http provider (used to grab your IP address)
    version     = "~> 1.2"
}


# This is us utilising and invoking the VPC module
module "vpc" {
    source = "../../modules/vpc"

    # Definining required variables (all are pulled from terraform.tfvars file)
    cluster_name                = var.cluster_name
    vpc_name                    = var.vpc_name
    cidr_block                  = var.cidr_block
    availability_zone_names     = var.availability_zone_names
    private_subnet_ranges       = var.private_subnet_ranges
    public_subnet_ranges        = var.public_subnet_ranges
}

module "security-groups" {
    source                      = "../../modules/security-groups"

    # Here we grab the outputs from the VPC module and 
    # we feed them as inputs to our security groups module
    vpc_id                      = module.vpc.eks_vpc_id
    cluster_name                = var.cluster_name
}

module "auto-scaling-groups" {
    source                      = "../../modules/auto-scaling-groups"

    cluster_name                = var.cluster_name
    eks_public_subnet_ids       = module.vpc.eks_public_subnet_ids
    bastion_security_group_ids  = [module.security-groups.bastion_security_group]
    ec2_key_public_key          = var.ec2_key_public_key
}

module "eks" {
    source                      = "../../modules/eks"
    aws_region                  = var.region
    cluster_name                = var.cluster_name
    kubernetes_version          = var.kubernetes_version
    cluster_security_group_ids  = [module.security-groups.cluster_security_group]
    node_security_group_ids     = [module.security-groups.node_security_group]
    private_subnet_ids          = module.vpc.eks_private_subnet_ids
}

