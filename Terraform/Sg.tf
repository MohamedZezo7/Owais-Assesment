resource "aws_security_group" "security_group" {
  vpc_id      = aws_vpc.main.id
  description = "Allowing Jenkins, Prometheus, Grafana , SSH Access"

  ingress = [
    for port in [22, 443, 8080, 9000, 9090, 80, 9100, 3000, 9200, 5601,5044 ] : {
      description      = "TLS from VPC"
      from_port        = port
      to_port          = port
      protocol         = "tcp"
      ipv6_cidr_blocks = ["::/0"]
      self             = false
      prefix_list_ids  = []
      security_groups  = []
      cidr_blocks      = ["0.0.0.0/0"]
    }
  ]

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.sg_name
  }
}

resource "aws_security_group" "rds_sg" {
  vpc_id      = aws_vpc.main.id
  description = "Allow MySQL access from the app security group"

  ingress {
    from_port       = 3306
    to_port         = 3306
    protocol        = "tcp"
    security_groups = [aws_security_group.security_group.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    self        = true
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = var.rds_sg_name
  }
}
