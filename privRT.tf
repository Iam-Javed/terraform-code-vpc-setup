resource "aws_route_table" "privRT" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.natgw.id
  }
}

resource "aws_route_table_association" "priv1RT" {
  subnet_id      = aws_subnet.privsub1.id
  route_table_id = aws_route_table.privRT.id
}
resource "aws_route_table_association" "priv2RT" {
  subnet_id      = aws_subnet.privsub2.id
  route_table_id = aws_route_table.privRT.id
}