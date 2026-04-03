#source provider
terraform {
  required_providers {
    aws={
        source = "hashicorp/aws"
        version = "~>5.0"
    }
  }
}

#provider configuration
provider "aws" {
    region="us-east-1"
}

#VPC setup
resource "aws_vpc" "main-vpc" {
    cidr_block="172.20.0.0/16"
    tags={
        name="main-vpc"
    }
}

#subnets 2 pub and 2 private from above vpc
resource "aws_subnet" "pubsub1" {
    vpc_id=aws_vpc.main-vpc.id
    cidr_block="172.20.1.0/24"
    availability_zone="us-east-1a"
    map_public_ip_on_launch=true
}
resource "aws_subnet" "pubsub2" {
    vpc_id=aws_vpc.main-vpc.id
    cidr_block="172.20.2.0/24"
    availability_zone="us-east-1b"
    map_public_ip_on_launch=true
}

resource "aws_subnet" "privsub1" {
    vpc_id=aws_vpc.main-vpc.id
    cidr_block="172.20.3.0/24"
    availability_zone="us-east-1a"
}
resource "aws_subnet" "privsub2" {
    vpc_id=aws_vpc.main-vpc.id
    cidr_block="172.20.4.0/24"
    availability_zone="us-east-1b"
}

#internet gateway
resource "aws_internet_gateway" "main-igw" {
    vpc_id=aws_vpc.main-vpc.id
    tags={
        name="main-igw"
    }
}

#public route table
resource "aws_route_table" "pub-rt" {
    vpc_id=aws_vpc.main-vpc.id
    tags={
        name="pub-rt"
    }

    route {
        cidr_block="0.0.0.0/0"
        gateway_id=aws_internet_gateway.main-igw.id
    }
}
#route table association for public subnets
resource "aws_route_table_association" "pubsub1-assoc" {
    subnet_id=aws_subnet.pubsub1.id
    route_table_id=aws_route_table.pub-rt.id
}
resource "aws_route_table_association" "pubsub2-assoc" {
    subnet_id=aws_subnet.pubsub2.id
    route_table_id=aws_route_table.pub-rt.id
}

#nat gateway for private subnets
resource "aws_eip" "nat-eip" {
    domain="vpc"
    tags={
        name="nat-eip"
    }
}
resource "aws_nat_gateway" "nat-gw" {
    allocation_id=aws_eip.nat-eip.id
    subnet_id=aws_subnet.pubsub1.id
    tags={
        name="nat-gw"
    }
}

#private route table
resource "aws_route_table" "priv-rt" {
    vpc_id=aws_vpc.main-vpc.id
    tags={
        name="priv-rt"
    }

    route {
        cidr_block="0.0.0.0/0"
        nat_gateway_id=aws_nat_gateway.nat-gw.id
    }
}
#route table association for private subnets
resource "aws_route_table_association" "privsub1-assoc" {
    subnet_id=aws_subnet.privsub1.id
    route_table_id=aws_route_table.priv-rt.id
}
resource "aws_route_table_association" "privsub2-assoc" {
    subnet_id=aws_subnet.privsub2.id
    route_table_id=aws_route_table.priv-rt.id
}

#key pair for ec2 instances
resource "aws_key_pair" "main-key" {
    key_name="main-key"
    public_key=file("~/Downloads/terraform-final-chapter/tf-key.pub")
}

#ami for ec2 instances
data "aws_ami" "ubuntu" {
    most_recent=true
    filter {
        name="name"
        values=["ubuntu/images/hvm-ssd/ubuntu-focal-20.04-amd64-server-*"]
    }
    filter {
        name="virtualization-type"
        values=["hvm"]
    }
    owners=["099720109477"] # Canonical
}

#security group for ec2 instances
resource "aws_security_group" "main-sg" {
    name="main-sg"
    description="Allow SSH and HTTP"
    vpc_id=aws_vpc.main-vpc.id

    ingress {
        from_port=22
        to_port=22
        protocol="tcp"
        cidr_blocks=["49.205.244.36/32"]
    }
    ingress {
        from_port=80
        to_port=80
        protocol="tcp"
        cidr_blocks=["0.0.0.0/0"]
    }
    egress {
        from_port=0
        to_port=0
        protocol="-1"
        cidr_blocks=["0.0.0.0/0"]
    }
    egress {
        from_port=0
        to_port=0
        protocol="-1"
        ipv6_cidr_blocks=["::/0"]
    }
}

#security group for load balancer
resource "aws_security_group" "lb-sg" {
    name="lb-sg"
    description="Allow HTTP from anywhere"
    vpc_id=aws_vpc.main-vpc.id

    ingress {
        from_port=80
        to_port=80
        protocol="tcp"
        cidr_blocks=["0.0.0.0/0"]
    }
    egress {
        from_port=0
        to_port=0
        protocol="-1"
        cidr_blocks=["0.0.0.0/0"]
    }
    egress {
        from_port=0
        to_port=0
        protocol="-1"
        ipv6_cidr_blocks=["::/0"]
    }
}

#ubuntu ec2 instance in public subnet
resource "aws_instance" "web-server" {
    count = 2
    ami=data.aws_ami.ubuntu.id
    instance_type="t3.micro"
    subnet_id=aws_subnet.pubsub1.id
    key_name=aws_key_pair.main-key.key_name
    vpc_security_group_ids=[aws_security_group.main-sg.id]
    tags={
        name="web-server"
    }



    connection {
      type = "ssh"
      private_key = file("~/Downloads/terraform-final-chapter/tf-key")
      user = "ubuntu"
      host = self.public_ip
    }
    provisioner "file" {
        source      = "docker/Dockerfile"
        destination = "/home/ubuntu/Dockerfile"
    }
    
    provisioner "file" {
        source      = "docker/travel.tar.gz"
        destination = "/home/ubuntu/travel.tar.gz"
    }
    provisioner "remote-exec" {
        inline = [
            "sudo apt update",
            "sudo apt install -y ca-certificates curl gnupg lsb-release",
            "sudo install -m 0755 -d /etc/apt/keyrings",
            "sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc",
            "sudo chmod a+r /etc/apt/keyrings/docker.asc",
            "echo \"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable\" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null",
            "sudo apt update",
            "sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin",
            "sudo systemctl start docker",
            "sudo systemctl enable docker",
            "sudo usermod -aG docker ubuntu",
            "sudo -i",
            "docker build -t web-server-image .",
            "docker run -d -p 80:80 --name web-server-container web-server-image:latest"
        ]
    }
}


#load balancer for two web server instances
resource "aws_lb" "web-lb" {
    name="web-lb"
    internal=false
    load_balancer_type="application"
    security_groups=[aws_security_group.lb-sg.id]
    subnets=[aws_subnet.pubsub1.id, aws_subnet.pubsub2.id]
    tags={
        name="web-lb"
    }
}
#target group for load balancer
resource "aws_lb_target_group" "web-tg" {
    name="web-tg"
    port=80
    protocol="HTTP"
    vpc_id=aws_vpc.main-vpc.id
    health_check {
        path="/"
        interval=30
        timeout=5
        healthy_threshold=2
        unhealthy_threshold=2
        matcher="200-399"
    }
}
#listener for load balancer
resource "aws_lb_listener" "web-listener" {
    load_balancer_arn=aws_lb.web-lb.arn
    port=80
    protocol="HTTP"
    default_action {
        type="forward"
        target_group_arn=aws_lb_target_group.web-tg.arn
    }
}
#attach ec2 instances to target group
resource "aws_lb_target_group_attachment" "web-tg-attachment1" {
  target_group_arn = aws_lb_target_group.web-tg.arn
  target_id        = aws_instance.web-server[0].id
  port             = 80
}

resource "aws_lb_target_group_attachment" "web-tg-attachment2" {
  target_group_arn = aws_lb_target_group.web-tg.arn
  target_id        = aws_instance.web-server[1].id
  port             = 80
}

#outputs
output "instance_id" {
  value       = [aws_instance.web-server[*].id]
  description = "IDs of the web server instances"
}

output "web_server_public_ip" {
  value       = [aws_instance.web-server[*].public_ip]
  description = "Public IPs of the web servers"
}



#backend terraform state in s3
terraform {
  backend "s3" {
    bucket         = "my-terraform-vpc-statefile-bucket"
    key            = "env/dev/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
    #dynamodb_table = "terraform-locks" # optional but recommended
  }
}