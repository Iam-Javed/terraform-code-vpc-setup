resource "aws_security_group" "my-secG" {
  name = "my-secG"
  tags = {
    name = "my-secG"
  }
  vpc_id = aws_vpc.main.id
}
resource "aws_vpc_security_group_ingress_rule" "my_SSH" {
  security_group_id = aws_security_group.my-secG.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  cidr_ipv4         = "49.205.244.36/32"
}
resource "aws_vpc_security_group_ingress_rule" "my_HTTP" {
  security_group_id = aws_security_group.my-secG.id
  ip_protocol       = "tcp"
  from_port         = 80
  to_port           = 80
  cidr_ipv4         = "0.0.0.0/0"
}
resource "aws_vpc_security_group_ingress_rule" "my_ipv4" {
  security_group_id = aws_security_group.my-secG.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
resource "aws_vpc_security_group_ingress_rule" "my_ipv6" {
  security_group_id = aws_security_group.my-secG.id
  ip_protocol       = "-1"
  cidr_ipv6         = "::0/0"
}