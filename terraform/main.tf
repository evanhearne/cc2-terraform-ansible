provider "aws" {
    region = "us-east-1"
}

# VPC
resource "aws_vpc" "main" {
    cidr_block           = "10.0.0.0/16"
    enable_dns_support   = true
    enable_dns_hostnames = true
    tags = {
        Name = "main-vpc"
    }
}

# Internet Gateway
resource "aws_internet_gateway" "main" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "main-igw"
    }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
    tags = {
        Name = "nat-eip"
    }
}

# NAT Gateway
resource "aws_nat_gateway" "main" {
    allocation_id = aws_eip.nat.id
    subnet_id     = aws_subnet.public.id
    tags = {
        Name = "private-nat-gateway"
    }
}

# Public Subnet
resource "aws_subnet" "public" {
    vpc_id                  = aws_vpc.main.id
    cidr_block              = "10.0.1.0/24"
    map_public_ip_on_launch = true
    availability_zone       = "us-east-1a"
    tags = {
        Name = "public-subnet"
    }
}

# Private Subnet
resource "aws_subnet" "private" {
    vpc_id            = aws_vpc.main.id
    cidr_block        = "10.0.2.0/24"
    availability_zone = "us-east-1a"
    tags = {
        Name = "private-subnet"
    }
}

# Public Route Table
resource "aws_route_table" "public" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "public-rt"
    }
}

# Public Route
resource "aws_route" "public" {
    route_table_id         = aws_route_table.public.id
    destination_cidr_block = "0.0.0.0/0"
    gateway_id             = aws_internet_gateway.main.id
}

# Public Route Table Association
resource "aws_route_table_association" "public" {
    subnet_id      = aws_subnet.public.id
    route_table_id = aws_route_table.public.id
}

# Private Route Table
resource "aws_route_table" "private" {
    vpc_id = aws_vpc.main.id
    tags = {
        Name = "private-rt"
    }
}

# Private Route
resource "aws_route" "private" {
    route_table_id         = aws_route_table.private.id
    destination_cidr_block = "0.0.0.0/0"
    nat_gateway_id         = aws_nat_gateway.main.id
}

# Private Route Table Association
resource "aws_route_table_association" "private" {
    subnet_id      = aws_subnet.private.id
    route_table_id = aws_route_table.private.id
}

# Security Group
resource "aws_security_group" "instance_sg" {
    vpc_id = aws_vpc.main.id
    name   = "instance-sg"

    ingress {
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    ingress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }

    tags = {
        Name = "instance-sg"
    }
}
# EC2 Instance
resource "aws_instance" "ha_proxy_lb" {
    ami           = data.aws_ami.amazon_linux.id
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.public.id
    security_groups = [aws_security_group.instance_sg.id]
    key_name      = "vockey" # Replace with your actual key pair name
    tags = {
        Name = "ha-proxy-lb"
    }
}

# Apache Instance 1
resource "aws_instance" "apache_instance_1" {
    ami           = data.aws_ami.amazon_linux.id
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.private.id
    security_groups = [aws_security_group.instance_sg.id]
    key_name      = "vockey" # Replace with your actual key pair name
    tags = {
        Name = "apache-instance-1"
    }
}

# Apache Instance 2
resource "aws_instance" "apache_instance_2" {
    ami           = data.aws_ami.amazon_linux.id
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.private.id
    security_groups = [aws_security_group.instance_sg.id]
    key_name      = "vockey" # Replace with your actual key pair name
    tags = {
        Name = "apache-instance-2"
    }
}

# Data source to fetch the latest Amazon Linux 2 AMI using SSM Parameter
data "aws_ssm_parameter" "amazon_linux" {
    name = "/aws/service/canonical/ubuntu/server/22.04/stable/current/amd64/hvm/ebs-gp2/ami-id"
}

data "aws_ami" "amazon_linux" {
    most_recent = true
    owners      = ["amazon"]
    filter {
        name   = "image-id"
        values = [data.aws_ssm_parameter.amazon_linux.value]
    }
}