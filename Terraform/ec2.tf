resource "aws_instance" "ec2" {
  ami                    = var.ami
  instance_type          = var.instance_type
  key_name               = aws_key_pair.mykey.key_name
  subnet_id              = aws_subnet.public_subnet.id
  vpc_security_group_ids = [aws_security_group.security_group.id]
  iam_instance_profile   = aws_iam_instance_profile.instance_profile.name

  root_block_device {
    volume_size = var.volume_size
  }

  user_data = templatefile("${path.module}/script.sh", {})

  tags = {
    Name = var.instance_name
  }
}

resource "tls_private_key" "pk" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = tls_private_key.pk.public_key_openssh

  provisioner "local-exec" {
    command = "echo '${tls_private_key.pk.private_key_pem}' > ../ansible/mykey.pem && chmod 400 mykey.pem"
  }
}
