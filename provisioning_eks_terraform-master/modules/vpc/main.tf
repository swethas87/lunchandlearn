resource "aws_vpc" "eks-vpc" {
  cidr_block = var.cidr_block

  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    "Name" = var.vpc_name

    # Depending on EKS versions, the tag below MUST be in place, see the VPC tagging requirement
    # https://docs.aws.amazon.com/eks/latest/userguide/network_reqs.html
    "kubernetes.io/cluster/${var.cluster_name}" = "shared"
  }
}

resource "aws_subnet" "eks-vpc-private-subnet" {
  # This will create the amount of required subnets 
  # in each availability zone for you given region
  # Here's how we do a form of looping with Terraform
  count = length(var.availability_zone_names)

  # Here we choose each zone and the corresponding subnet for each
  availability_zone = var.availability_zone_names[count.index]
  cidr_block        = var.private_subnet_ranges[count.index]

  # Here we relate this subnet to the eks-vpc define above
  vpc_id = aws_vpc.eks-vpc.id

  tags = map(
    "Name", "${var.vpc_name}-${var.availability_zone_names[count.index]}-private-subnet",
    "kubernetes.io/cluster/${var.cluster_name}", "shared",
    "kubernetes.io/role/internal-elb", 1
  )
}

resource "aws_subnet" "eks-vpc-public-subnet" {
  # This will create the amount of required subnets 
  # in each availability zone for you given region
  # Here's how we do a form of looping with Terraform
  count = length(var.availability_zone_names)

  # Here we choose each zone and the corresponding subnet for each
  availability_zone = var.availability_zone_names[count.index]
  cidr_block        = var.public_subnet_ranges[count.index]

  # Here we relate this subnet to the eks-vpc define above
  vpc_id = aws_vpc.eks-vpc.id

  # Details on tagging requirements for subnet discovery
  # https://aws.amazon.com/premiumsupport/knowledge-center/eks-vpc-subnet-discovery/
  tags = map(
    "Name", "${var.vpc_name}-${var.availability_zone_names[count.index]}-public-subnet",
    "kubernetes.io/cluster/${var.cluster_name}", "shared",
    "kubernetes.io/role/elb", 1
  )
}

# Create the Internet Gateway associated with the VPC
# To allow us to get out to the Internet
resource "aws_internet_gateway" "eks-internet-gateway" {
  vpc_id = aws_vpc.eks-vpc.id

  tags = {
    Name = "${var.vpc_name}-internet-gateway"
  }
}

# Create an Elastic IP for each Nat Gateway
resource "aws_eip" "eks-nat-elastic-ip" {

  count = length(var.public_subnet_ranges)

  vpc = true

  tags = {
    "Name" = "eks-${var.availability_zone_names[count.index]}-eip"
  }

  depends_on = [aws_internet_gateway.eks-internet-gateway, aws_subnet.eks-vpc-public-subnet]
}

# Create a NAT gateway for each of the public subnets
# Follow this video for the purpose of a NAT Gateway
# https://www.youtube.com/watch?v=ujXr0i5EoHE

resource "aws_nat_gateway" "public-subnet-nat-gateway" {
  count = length(aws_subnet.eks-vpc-public-subnet.*.id)

  allocation_id = aws_eip.eks-nat-elastic-ip[count.index].id
  subnet_id     = aws_subnet.eks-vpc-public-subnet[count.index].id

  tags = {
    Name = "eks-nat-gateway-${aws_subnet.eks-vpc-public-subnet[count.index].tags.Name}"
  }

  depends_on = [aws_eip.eks-nat-elastic-ip, aws_subnet.eks-vpc-public-subnet]
}

# Route Tables for the public routes

resource "aws_route_table" "eks-public" {

  vpc_id = aws_vpc.eks-vpc.id

  tags = {
    "Name" = "${var.cluster_name}-public-route-table"
  }
}

resource "aws_route" "public-internet-gateway" {

  route_table_id         = aws_route_table.eks-public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.eks-internet-gateway.id

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "public-subnet-route-table-association" {
  count = length(aws_subnet.eks-vpc-public-subnet.*.id)

  subnet_id      = aws_subnet.eks-vpc-public-subnet[count.index].id
  route_table_id = aws_route_table.eks-public.id
}

# Route Tables for the private routes

resource "aws_route_table" "eks-private" {
  count = length(aws_subnet.eks-vpc-private-subnet.*.id)

  vpc_id = aws_vpc.eks-vpc.id

  tags = {
    "Name" = "${var.cluster_name}-private-route-table-${aws_subnet.eks-vpc-private-subnet[count.index].id}"
  }

  lifecycle {
    # When attaching VPN gateways it is common to define aws_vpn_gateway_route_propagation
    # resources that manipulate the attributes of the routing table (typically for the private subnets)
    ignore_changes = [propagating_vgws]
  }
}

resource "aws_route" "private-nat-gateway" {
  count = length(aws_subnet.eks-vpc-private-subnet.*.id)

  route_table_id         = element(aws_route_table.eks-private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.public-subnet-nat-gateway.*.id, count.index)

  timeouts {
    create = "5m"
  }
}

resource "aws_route_table_association" "private-subnet-route-table-association" {
  count = length(aws_subnet.eks-vpc-private-subnet.*.id)

  subnet_id      = aws_subnet.eks-vpc-private-subnet[count.index].id
  route_table_id = aws_route_table.eks-private[count.index].id
}
