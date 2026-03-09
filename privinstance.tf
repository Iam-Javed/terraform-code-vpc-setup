resource "aws_instance" "priv-server" {
  ami             = data.aws_ami.ubuntu-server.id
  instance_type   = var.instance_type
  key_name = aws_key_pair.my-key.key_name
  subnet_id       = aws_subnet.privsub1.id
  security_groups = [aws_security_group.privSecG.id]

  tags = {
    name = "priv-server"
  }
}

output "instance_id" {
  description = "id of instance"
  value       = aws_instance.main-server.id
}
output "instance_public_ip" {
  description = "ip of instance"
  value       = aws_instance.main-server.private_ip
}