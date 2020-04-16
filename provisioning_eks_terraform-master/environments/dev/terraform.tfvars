region                      = "eu-west-2"
cluster_name                = "eks-cluster"
vpc_name                    = "eks-vpc"
cidr_block                  = "10.0.0.0/16"
availability_zone_names     = ["eu-west-2a", "eu-west-2b"]
private_subnet_ranges       = ["10.0.0.0/19", "10.0.32.0/19"]
public_subnet_ranges        = ["10.0.128.0/20", "10.0.144.0/20"]
kubernetes_version          = "1.15"