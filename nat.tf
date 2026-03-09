resource "aws_eip" "nat_eip" {
  domain = "vpc"
}

resource "aws_nat_gateway" "natgw" {
  subnet_id     = aws_subnet.pubsub1.id
  allocation_id = aws_eip.nat_eip.id
}