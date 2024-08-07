resource "aws_vpc" "vpc" {
    cidr_block = "18.0.0.0/16"
}
resource "aws_internet_gateway" "igw" {
    vpc_id = aws_vpc.vpc.id
}
resource "aws_subnet" "subnet_1" {
    vpc_id = aws_vpc.vpc.id
    cidr_block = "18.0.1.0/24"
    availability_zone = "ap-south-1a"
}
resource "aws_route_table" "rt" {
    vpc_id = aws_vpc.vpc.id
    route  {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.igw.id
    }
}
resource "aws_route_table_association" "a" {
    subnet_id = aws_subnet.subnet_1.id
    route_table_id = aws_route_table.rt.id
}
resource "aws_security_group" "sg1" {
    vpc_id = aws_vpc.vpc.id
    #allow ssh
    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
      #allow http
   ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
resource "aws_key_pair" "key" {
    key_name = "KEY"
    public_key = tls_private_key.rsa.public_key_openssh
}
resource "tls_private_key" "rsa" {
    algorithm = "RSA"
    rsa_bits = 4096
}
resource "local_file" "tf_key" {
    content = tls_private_key.rsa.private_key_pem
    filename = "key.pem"
}
resource "aws_instance" "virtual_server" {
    ami = var.ami_id
    instance_type = var.instance_type
    key_name = aws_key_pair.key.key_name
    subnet_id = aws_subnet.subnet_1.id
    vpc_security_group_ids = [aws_security_group.sg1.id]
    associate_public_ip_address = true
    tags ={
        Name = "virtual-server-ec2"
    }
}
