variable "region" {
    default = "eu-west-2"
}

variable "cluster_name" {}

variable "vpc_name" {}

variable "cidr_block" {}

variable "availability_zone_names" {}

variable "private_subnet_ranges" {}

variable "public_subnet_ranges" {}

variable "ec2_key_public_key" {
    default = "ssh-rsa REPLACE_ME"
}

variable "kubernetes_version" {}

