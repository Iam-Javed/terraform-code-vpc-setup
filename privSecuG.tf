resource "aws_security_group" "privSecG" {
  name = "privSecG"
  tags = {
    name = "privSecG"
  }
  vpc_id = aws_vpc.main.id
}
resource "aws_vpc_security_group_ingress_rule" "priv_SSH" {
  security_group_id = aws_security_group.privSecG.id
  ip_protocol       = "tcp"
  from_port         = 22
  to_port           = 22
  referenced_security_group_id = aws_security_group.my-secG.id
}

resource "aws_vpc_security_group_ingress_rule" "priv_ipv4" {
  security_group_id = aws_security_group.privSecG.id
  ip_protocol       = "-1"
  cidr_ipv4         = "0.0.0.0/0"
}
resource "aws_vpc_security_group_ingress_rule" "priv_ipv6" {
  security_group_id = aws_security_group.privSecG.id
  ip_protocol       = "-1"
  cidr_ipv6         = "::0/0"
}