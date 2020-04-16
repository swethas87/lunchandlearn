
# In production we would only SSH to the bastion in order to run kubectl commands
resource "aws_security_group" "bastion-ssh" {
  name        = "EKS Bastion SSH"
  description = "Allow SSH from specific IP addresses to bastion"
  vpc_id      = var.vpc_id

  ingress {
    description = "SSH to Bastion"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"

    # Here we allow access from your own machine
    # Please add further IP addresses for other machines
    cidr_blocks = ["${chomp(data.http.workstation-external-ip.body)}/32"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "EKS Bastion SSH"
  }
}

resource "aws_security_group" "cluster-security-group" {
  name        = "EKS Cluster Security Group"
  description = "Cluster communication with worker nodes"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name" = "EKS Cluster Security Group"
  }
}

resource "aws_security_group" "node-security-group" {
  name        = "EKS Node Security Group"
  description = "Security group for all nodes in the cluster"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    "Name"                                      = "EKS Node Security Group"
    "kubernetes.io/cluster/${var.cluster_name}" = "owned"
  }
}

# For the purposes of our course we'll also open up port 443 to our workstation
# You would likely disable this in production and only use the bastions for kubectl access
resource "aws_security_group_rule" "eks-cluster-ingress-workstation-https" {
  cidr_blocks       = ["${chomp(data.http.workstation-external-ip.body)}/32"]
  description       = "Allow workstation to communicate with the cluster API Server"
  from_port         = 443
  protocol          = "tcp"
  security_group_id = aws_security_group.cluster-security-group.id
  to_port           = 443
  type              = "ingress"
}

resource "aws_security_group_rule" "cluster-node-ingress-self" {
  description              = "Allow kubernetes nodes to communicate with each other"
  from_port                = 0
  protocol                 = "-1"
  security_group_id        = aws_security_group.cluster-security-group.id
  source_security_group_id = aws_security_group.cluster-security-group.id
  to_port                  = 65535
  type                     = "ingress"
}

resource "aws_security_group_rule" "cluster-node-ingress-kubernetes-master" {
  description              = "Allow worker Kubelets and pods to receive communication from the cluster control plane"
  from_port                = 1025
  protocol                 = "tcp"
  security_group_id        = aws_security_group.node-security-group.id
  source_security_group_id = aws_security_group.cluster-security-group.id
  to_port                  = 65535
  type                     = "ingress"
 }

 resource "aws_security_group_rule" "cluster-node-ingress-https" {
  description              = "Allow pods to communicate with the cluster API Server"
  from_port                = 443
  protocol                 = "tcp"
  security_group_id        = aws_security_group.cluster-security-group.id
  source_security_group_id = aws_security_group.node-security-group.id
  to_port                  = 443
  type                     = "ingress"
}