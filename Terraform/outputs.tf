output "ec2_instance_ip" {
  value = aws_instance.ec2.public_ip
}
output "rds_cluster_endpoint" {
  value = aws_rds_cluster.rds_cluster.endpoint
}

output "rds_cluster_port" {
  value = aws_rds_cluster.rds_cluster.port
}

