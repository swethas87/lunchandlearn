output "bastion_security_group" {
  value = aws_security_group.bastion-ssh.id
}

output "cluster_security_group" {
  value = aws_security_group.cluster-security-group.id
}

output "node_security_group" {
  value = aws_security_group.node-security-group.id
}