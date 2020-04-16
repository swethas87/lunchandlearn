data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "deployer" {
  key_name   = var.cluster_name
  public_key = var.ec2_key_public_key
}

resource "aws_launch_configuration" "bastion-launch-configuration" {
  name                          = "bastion-launch-configuration"
  image_id                      = data.aws_ami.ubuntu.id
  instance_type                 = "t2.small"
  security_groups               = var.bastion_security_group_ids
  associate_public_ip_address   = true
  key_name                      = aws_key_pair.deployer.key_name

  root_block_device {
    volume_size           = "10"
    volume_type           = "gp2"
    delete_on_termination = true
  }

}

resource "aws_autoscaling_group" "eks-cluster-bastion" {
  name                      = "${var.cluster_name}-bastion"
  max_size                  = 1
  min_size                  = 1
  desired_capacity          = 1
  wait_for_capacity_timeout = 0
  health_check_type         = "EC2"

  launch_configuration = aws_launch_configuration.bastion-launch-configuration.name
  vpc_zone_identifier  = var.eks_public_subnet_ids

  tags = [
    {
      key                 = "kubernetes.io/cluster/${var.cluster_name}"
      value               = "owned"
      propagate_at_launch = true
    }
  ]
}
