provider "aws" {
  region = "us-east-1"
}

# --- 1. NETWORK FOUNDATION (The "Land") ---

# The Virtual Private Cloud (VPC)
# This is your private slice of the AWS cloud.
resource "aws_vpc" "main_vpc" {
  cidr_block           = "10.0.0.0/16" # Allows 65,536 IP addresses
  enable_dns_support   = true
  enable_dns_hostnames = true
  tags = { Name = "schedemy-vpc-high-tier" }
}

# Internet Gateway (IGW)
# The "Front Door" that allows traffic to enter/leave the VPC.
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main_vpc.id
  tags   = { Name = "schedemy-igw" }
}

# --- 2. SUBNETS (The "Rooms") ---

# Public Subnets (For Load Balancer & NAT Gateway)
# These CAN talk to the internet directly.
resource "aws_subnet" "public_1" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.1.0/24"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
  tags                    = { Name = "public-subnet-1" }
}

resource "aws_subnet" "public_2" {
  vpc_id                  = aws_vpc.main_vpc.id
  cidr_block              = "10.0.2.0/24"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
  tags                    = { Name = "public-subnet-2" }
}

# Private Subnets (For Application Servers)
# These are HIDDEN. No direct internet access.
resource "aws_subnet" "private_1" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.3.0/24"
  availability_zone = "us-east-1a"
  tags              = { Name = "private-subnet-1" }
}

resource "aws_subnet" "private_2" {
  vpc_id            = aws_vpc.main_vpc.id
  cidr_block        = "10.0.4.0/24"
  availability_zone = "us-east-1b"
  tags              = { Name = "private-subnet-2" }
}

# --- 3. ROUTING (The "Map") ---

# Public Route Table
# Tells traffic: "If you want to go to the internet (0.0.0.0/0), use the IGW."
resource "aws_route_table" "public_rt" {
  vpc_id = aws_vpc.main_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }
  tags = { Name = "public-route-table" }
}

# Associate Public Subnets with the Public Route Table
resource "aws_route_table_association" "public_1_assoc" {
  subnet_id      = aws_subnet.public_1.id
  route_table_id = aws_route_table.public_rt.id
}
resource "aws_route_table_association" "public_2_assoc" {
  subnet_id      = aws_subnet.public_2.id
  route_table_id = aws_route_table.public_rt.id
}

# --- 4. SECURITY GROUPS (The "Firewalls") ---

# ALB Security Group
# Allows the whole world to access port 80 (HTTP).
resource "aws_security_group" "alb_sg" {
  name        = "schedemy-alb-sg"
  description = "Allow HTTP inbound traffic"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description = "HTTP from Internet"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "schedemy-alb-sg" }
}

# App Security Group
# The Distinction part: It ONLY accepts traffic from the ALB.
# If a hacker tries to connect directly, they get blocked.
resource "aws_security_group" "app_sg" {
  name        = "schedemy-app-sg"
  description = "Allow traffic from ALB only"
  vpc_id      = aws_vpc.main_vpc.id

  ingress {
    description     = "HTTP from ALB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb_sg.id] # Only ALB is allowed
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = { Name = "schedemy-app-sg" }
}
