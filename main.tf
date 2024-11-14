provider "aws" {
  region = "us-west-2"
}

# My VPC
resource "aws_vpc" "Diamond_VPC" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true
}

# EC2 for my Public Subnet
resource "aws_instance" "public_instance" {
  ami           = "ami-04dd23e62ed049936"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.public_subnet.id
  key_name      = dms_keypair #create a keypair to connect via ssh 
  tags = {
    Name = "PublicInstance"
  }
}

# EC2 for my Private Subnet
resource "aws_instance" "private_instance" {
  ami           = "ami-04dd23e62ed049936"
  instance_type = "t2.micro"
  subnet_id     = aws_subnet.private_subnet.id

  tags = {
    Name = "PrivateInstance"
  }
}

# My Public Subnet for my public EC2, NAT and Router connection to the IGW
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.Diamond_VPC.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-west-2a"
  map_public_ip_on_launch = true
}

# My Private Subnet for my Private EC2, 
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.Diamond_VPC.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "us-west-2b"
}

# My IGW to connect to my route table which is connected to my Public Subnet
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.Diamond_VPC.id
}

# My NAT Gateway for my public Subnet
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
}

# My Elastic IP Address for my NAT
resource "aws_eip" "nat_eip" {

}

# Public Route Table
resource "aws_route_table" "public_route_table" {
  vpc_id = aws_vpc.Diamond_VPC.id
}

# Public Route to connect my route table to my IGW for Internet communication
resource "aws_route" "public_route_internet" {
  route_table_id         = aws_route_table.public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# I have to associate the Public Route Table with my Public Subnet
resource "aws_route_table_association" "public_route_table_association" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_route_table.id
}

# My private Route Table
resource "aws_route_table" "private_route_table" {
  vpc_id = aws_vpc.Diamond_VPC.id
}

# Private Route to connect my NAT Gateway to establish communication with the EC2 in my Private Subnet
resource "aws_route" "private_route_nat" {
  route_table_id         = aws_route_table.private_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# I have to associate the Private Route Table with my Private Subnet
resource "aws_route_table_association" "private_route_table_association" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_route_table.id
}

# My SG for the Private EC2 Instance
resource "aws_security_group" "private_instance_sg" {
  name        = "private-instance-sg"
  description = "Allow internal access and outbound traffic to NAT gateway"
  vpc_id      = aws_vpc.Diamond_VPC.id

  # My Inbound rules (ssh)
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = [aws_subnet.public_subnet.cidr_block]
  }

  # Outbound rules 
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "PrivateInstanceSG"
  }
}

output "Public_ec2" {
  value = aws_instance.public_instance.public_ip
}

# I am using the AWS default SG for my public EC2

