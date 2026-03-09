data "aws_ami" "ubuntu-server" {
  most_recent = true
  filter {
    name   = "name"
    values = var.ami
  }
  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = var.owners
}