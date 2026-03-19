# ---------------- PROVIDER ----------------
provider "aws" {
  region = "ap-south-1"
}

# ---------------- VPC ----------------
resource "aws_vpc" "main_vpc" {
  cidr_block = "10.0.0.0/16"

  tags = {
    Name = "simple-vpc"
  }
}

# ---------------- PUBLIC SUBNET ----------------
resource "aws_subnet" "public_subnet" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = true

  tags = {
    Name = "public-subnet"
  }
}

# ---------------- PRIVATE SUBNET ----------------
resource "aws_subnet" "private_subnet" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.2.0/24"
  availability_zone = "ap-south-1a"

  tags = {
    Name = "private-subnet"
  }
}

# ---------------- INTERNET GATEWAY ----------------
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
}

# ---------------- PUBLIC ROUTE TABLE ----------------
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public_rt.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.igw.id
}

# Associate public subnet
resource "aws_route_table_association" "public_assoc" {
  subnet_id      = aws_subnet.public_subnet.id
  route_table_id = aws_route_table.public_rt.id
}

# ---------------- ELASTIC IP ----------------
resource "aws_eip" "nat_eip" {
  depends_on = [aws_internet_gateway.igw]
}

# ---------------- NAT GATEWAY ----------------
resource "aws_nat_gateway" "nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.public_subnet.id
}

# ---------------- PRIVATE ROUTE TABLE ----------------
resource "aws_route_table" "private_rt" {
  vpc_id = aws_vpc.main_vpc.id
}

resource "aws_route" "private_internet" {
  route_table_id         = aws_route_table.private_rt.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.nat.id
}

# Associate private subnet
resource "aws_route_table_association" "private_assoc" {
  subnet_id      = aws_subnet.private_subnet.id
  route_table_id = aws_route_table.private_rt.id
}

# ---------------- SECURITY GROUP ----------------
resource "aws_security_group" "web_sg" {
  vpc_id = aws_vpc.main_vpc.id

  # SSH
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # HTTP
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # Outbound
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}


resource "aws_key_pair" "my_key" {
  key_name =  "terraformkey"
  public_key = "terraformkey.pub" 
  
}

resource "aws_instance" "my_instan" {
 key_name = aws_key_pair.my_key.key_name
 ami = var.aws_ami_id 
 subnet_id = aws_subnet.public_subnet.id
 instance_type = "t2.micro"
 vpc_security_group_ids = [aws_security_group.web_sg.id]
 associate_public_ip_address = true


 tags{
  name = ["public_instance"]
 } 
}

resource "aws_instance" "my_Private_instan" {
 key_name = aws_key_pair.my_key.key_name
 ami = var.aws_ami_id 
 subnet_id = aws_subnet.private_subnet.id
 instance_type = "t2.micro"
 vpc_security_group_ids = [aws_security_group.web_sg.id]
 


 tags{
  name = ["private_instance"]
 } 
}