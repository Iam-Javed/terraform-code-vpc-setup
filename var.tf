#region
variable "region" {
  default = "us-east-1"
}

#ami ID
variable "ami" {
  default = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
}
variable "owners" {
    type = list(string)
    default = ["099720109477"]
}

variable "instance_type" {
  default = "t3.small"
}

#vpc and subnets
variable "vpc" {
  default = "172.20.0.0/16"
}

variable "pubsub1" {
  default = "172.20.1.0/24"
}
variable "pubsub2" {
  default = "172.20.2.0/24"
}
variable "privsub1" {
  default = "172.20.3.0/24"
}
variable "privsub2" {
  default = "172.20.4.0/24"
}

variable "az1" {
  default = "us-east-1a"
}
variable "az2" {
  default = "us-east-1b"
}