
// Select terraform provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}


// Define provider
provider "aws" {
  profile = "squareops"
  region  = "ap-south-1"
}

// Define VPC resources
resource "aws_vpc" "my_vpc" {
    cidr_block = var.cidr_block_vpc         #"10.0.0.0/16"
    enable_dns_support = "true" #gives you an internal domain name
    enable_dns_hostnames = "true" #gives you an internal host name  

    tags = {
        Name = "${var.tag_name}-${var.vpc_name}" # Tag all resource with specific name.......String Interpolation
    }
}

// Fetch AZs
data "aws_availability_zones" "available" {
  state = "available"
}

// Define Public subnet resources
resource "aws_subnet" "my-public-subnet-1" {
  vpc_id                  = aws_vpc.my_vpc.id
                            // cidrsubnet fn returns cidr blocks based on prefix, newbits, netnum
  cidr_block              = cidrsubnet(var.cidr_block_vpc, 8, 0) #"10.0.0.0/24" 
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[0] #select 1st available AZ
  tags = {
    Name = "${var.tag_name}-public-1" # Tag all resource with specific name
  }
}

// Define Public subnet resources
resource "aws_subnet" "my-public-subnet-2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = cidrsubnet(var.cidr_block_vpc, 8, 1) #"10.0.1.0/24"
  map_public_ip_on_launch = "true"
  availability_zone       = data.aws_availability_zones.available.names[1] #select 2nd available AZ
  tags = {
    Name = "${var.tag_name}-public-2"
  }
}

// Define Private subnet resources
resource "aws_subnet" "my-private-subnet-1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = cidrsubnet(var.cidr_block_vpc, 8, 2) #"10.0.2.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = data.aws_availability_zones.available.names[0]
  tags = {
    Name = "${var.tag_name}-private-1"
  }
}

// Define Private subnet resources
resource "aws_subnet" "my-private-subnet-2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = cidrsubnet(var.cidr_block_vpc, 8, 3) #"10.0.3.0/24"
  map_public_ip_on_launch = "false"
  availability_zone       = data.aws_availability_zones.available.names[1]
  tags = {
    Name = "${var.tag_name}-private-2"
  }
}


// Define IGW resource
resource "aws_internet_gateway" "my-igw" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name = "${var.tag_name}-IGW"
  }
  depends_on = [aws_vpc.my_vpc]
}

// Define EIP resource
resource "aws_eip" "nat_eip" {
  vpc        = true
  depends_on = [aws_internet_gateway.my-igw]
}

// Define NAT Gateway resource
resource "aws_nat_gateway" "my-nat" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.my-public-subnet-1.id
  tags = {
    Name = "${var.tag_name}-NAT-gateway"
  }
  depends_on = [aws_eip.nat_eip]
}

// Define Public RT resource
resource "aws_route_table" "publicRT" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name   = "${var.tag_name}-public-RT"
  }
  depends_on = [aws_vpc.my_vpc]
}

// Define Private RT resource
resource "aws_route_table" "privateRT" {
  vpc_id = aws_vpc.my_vpc.id
  tags = {
    Name        = "${var.tag_name}-private-RT"
  }
  depends_on = [aws_vpc.my_vpc]
}

// Define Public RT Route resource
resource "aws_route" "public_route" {
  route_table_id         = "${aws_route_table.publicRT.id}"
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = "${aws_internet_gateway.my-igw.id}"
  depends_on = [aws_route_table.publicRT]
}

// Define Private RT Route resource
resource "aws_route" "private_nat_gateway" {
  route_table_id         = "${aws_route_table.privateRT.id}"
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = "${aws_nat_gateway.my-nat.id}"
  depends_on = [aws_route_table.privateRT]
}

// Public subnet-1 RT Association resource
resource "aws_route_table_association" "public1" {
  subnet_id      = aws_subnet.my-public-subnet-1.id
  route_table_id = aws_route_table.publicRT.id
}

// Public subnet-2 RT Association resource
resource "aws_route_table_association" "public2" {
  subnet_id      = aws_subnet.my-public-subnet-2.id
  route_table_id = aws_route_table.publicRT.id
}

// Private subnet-1 RT Association resource
resource "aws_route_table_association" "private1" {
  subnet_id      = aws_subnet.my-private-subnet-1.id
  route_table_id = aws_route_table.privateRT.id
}

// Private subnet-2 RT Association resource
resource "aws_route_table_association" "private2" {
  subnet_id      = aws_subnet.my-private-subnet-2.id
  route_table_id = aws_route_table.privateRT.id
}



# // Set terraform output as ENV
# resource "null_resource" "execShell" {
#   depends_on = [aws_route_table.privateRT]
#   provisioner "local-exec" {
#     command = "terraform output > out.txt"
#     interpreter = ["PowerShell", "-Command"]
#   }
# }
