output "ec2_instance_ip" {
  value = aws_instance.ec2.public_ip
}
output "rds_cluster_endpoint" {
  value = aws_rds_cluster.rds_cluster.endpoint
}

output "rds_cluster_port" {
  value = aws_rds_cluster.rds_cluster.port
}

output "rds_cluster_password" {
  value = aws_secretsmanager_secret_version.rds_credentials_version.secret_string
}