resource "aws_subnet" "pubsub1" {
  vpc_id                                         = aws_vpc.main.id
  cidr_block                                     = var.pubsub1
  availability_zone                              = var.az1
  map_public_ip_on_launch                        = true
}
resource "aws_subnet" "pubsub2" {
  vpc_id                                         = aws_vpc.main.id
  cidr_block                                     = var.pubsub2
  availability_zone                              = var.az2
  map_public_ip_on_launch                        = true
}
resource "aws_subnet" "privsub1" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.privsub1
  availability_zone = var.az1
}
resource "aws_subnet" "privsub2" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.privsub2
  availability_zone = var.az2
}