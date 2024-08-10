
# CODTECH-Task-2
- Name:Chatla Tharun
- Company:CODTECH IT SOLUTIONS
- ID:CT12DS1611
- Domain:DevOps
- Duration:July to September 2024
- Mentor:SANTHOSH
# overview of the project
## Project: Automating the Infrastructure of AWS EC2 Instances Using Terraform
# *Objectives*
- Understand the basics of Terraform and its configuration language (HCL)
- how to write Terraform configuration files to define infrastructure resources
- Use Terraform commands to apply and destroy infrastructure
# *Tools*
- **Cloud platform**: AWS
- **AWS CLI**: Command Line Interface for managing AWS services
- **Terraform**: Infrastructure as Code (IaC) tool for automating cloud infrastructure
- **HCL (HashiCorp Configuration Language)**: The language used for writing Terraform script files
# Project steps:
### step 1: Setup AWS instance
- Login to AWS console
- Head over to EC2 dashboard
- Launch instance
![Screenshot 2024-08-05 214838](https://github.com/user-attachments/assets/6f3fc756-8d70-427d-8748-b33144381712)
![Screenshot 2024-08-05 214921](https://github.com/user-attachments/assets/e5b46542-6e41-4c2e-a45b-94bb621f7468)
- Connect to your terminal using SSH client ![Screenshot 2024-08-05 214938](https://github.com/user-attachments/assets/1959de4f-9933-422a-9224-8c7a7693c9fa)
![Screenshot 2024-08-05 215304](https://github.com/user-attachments/assets/13880028-dc4f-4348-8f77-bbde45b3d879)
- Make it a root user(command=sudo -i or sudo su) , update using (command=apt update -y)
#### 1. unzip
- To install unzip use:
  ```apt install unzip -y```
![Screenshot 2024-08-05 215549](https://github.com/user-attachments/assets/4351871b-3b62-4963-a26c-6f3321f819f6)
#### 2. AWS CLI
- To install AWS CLI use:
 ```
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install
```
![Screenshot 2024-08-05 220417](https://github.com/user-attachments/assets/42a6e16c-a2f4-4941-8afa-1563a0ace666)
- To configure AWS
- Go to IAM and generate the Access key for CLI
```aws configure```
![Screenshot 2024-08-05 220938](https://github.com/user-attachments/assets/7ad9ba85-8898-4090-82d3-5883b0e51ccf)
#### 2. Terraform
- To install Terraform use:
```
wget -O- https://apt.releases.hashicorp.com/gpg | sudo gpg --dearmor -o /usr/share/keyrings/hashicorp-archive-keyring.gpg
echo "deb [signed-by=/usr/share/keyrings/hashicorp-archive-keyring.gpg] https://apt.releases.hashicorp.com $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/hashicorp.list
sudo apt update && sudo apt install terraform
```
![Screenshot 2024-08-05 221257](https://github.com/user-attachments/assets/a4b67e81-18b5-4ecf-b766-634c5738f9d9)
- create directory
```mkdir terraform```
- change to directory terraform
```cd terraform```
- create provider block
```touch provider.tf```
- And data to file using vi visual editor
```vi provider.tf```
```
terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = "5.61.0"
    }
  }
}
provider "aws" {
  region= "ap-south-1"
  profile= "default"
}
```
![Screenshot 2024-08-05 221954](https://github.com/user-attachments/assets/f766e896-fd84-4596-9703-f83c067486d9)
- create a variable block
```touch variable.tf```
- And data to file using vi visual editor
```
 variable "ami_id" {
    type = string
    default = "ami-0ad21ae1d0696ad58"
}
variable "instance_type" {
    type = string
    default = "t2.micro"
}
```
![Screenshot 2024-08-05 221954](https://github.com/user-attachments/assets/791cf15a-b942-4ca5-aa6c-eaf75ee1006a)
- create a resource block
```touch resource.tf```
- And data to file using vi visual editor
```
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
```
![Screenshot 2024-08-05 225116](https://github.com/user-attachments/assets/aa50148a-1c32-46ae-a881-a2ac09675ef8)
![Screenshot 2024-08-05 225153](https://github.com/user-attachments/assets/238b5c11-7c9f-47cf-96b1-f2fb4c2c334e)
- Then use terraform command
- terraform init -to downloads necessary plugins and providers (like AWS, Azure, etc.) that Terraform will use to manage resources
- terraform validate -to checks the syntax and configuration of your Terraform files
- terraform apply - to applies the changes defined in your Terraform files to your cloud provide
