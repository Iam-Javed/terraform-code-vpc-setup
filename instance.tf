resource "aws_instance" "main-server" {
  ami             = data.aws_ami.ubuntu-server.id
  instance_type   = var.instance_type
  key_name = aws_key_pair.my-key.key_name
  subnet_id       = aws_subnet.pubsub1.id
  security_groups = [aws_security_group.my-secG.id]

  tags = {
    name = "main-server"
  }
}

output "aws_instance_id" {
  description = "id of instance"
  value       = aws_instance.main-server.id
}
output "aws_instance_public_ip" {
  description = "ip of instance"
  value       = aws_instance.main-server.public_ip
}