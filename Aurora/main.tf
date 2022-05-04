
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

// Import VPC module to use outputs
module "myVPC" { // Run This module also
  source = "../VPC"
}

// Define sg for Application
resource "aws_security_group" "app-sg" {
  name        = "Rahul-tf-app"
  description = "Allow SSH traffic"
  vpc_id      = module.myVPC.VPC_ID #"vpc-04a220b2e6d81a4d5"

  // Incoming Traffic
  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  // outgoining traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = var.tag
  }
}

// Define Sg for DB
resource "aws_security_group" "db-sg" {
  depends_on = [aws_security_group.app-sg]
  name        = "Rahul-tf-RDS"
  description = "Allow MYSQL traffic for Application instance only"
  vpc_id      = module.myVPC.VPC_ID #"vpc-04a220b2e6d81a4d5"

  // Incoming Traffic
  ingress {
    description = "MySQL"
    from_port   = 3306
    to_port     = 3306
    protocol    = "tcp"
    security_groups = [aws_security_group.app-sg.id]
  }

  // outgoining traffic
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = {
    Name = var.tag
  }
}

// Fetch AZs
data "aws_availability_zones" "available" {
  state = "available"
}

// Define DB Subnet Group
resource "aws_db_subnet_group" "my_DBsubnet_group" {
  name       = var.db_subnet_group
  subnet_ids = [module.myVPC.Private_Subnet1_ID, module.myVPC.Private_Subnet2_ID]
  tags = {
    Name = var.tag
  }
}

// Define RDS Aurora Resource
resource "aws_rds_cluster_instance" "my_aurora" {
  depends_on = [aws_db_subnet_group.my_DBsubnet_group, aws_rds_cluster.my_rds_cluster]
  count              = 2
  identifier         = "rahul-tf-${count.index}"
  cluster_identifier = aws_rds_cluster.my_rds_cluster.id
  instance_class     = "db.t3.small"
  engine             = "aurora-mysql"
  db_subnet_group_name = var.db_subnet_group
}

resource "aws_rds_cluster" "my_rds_cluster" {
  depends_on = [aws_security_group.db-sg, aws_db_subnet_group.my_DBsubnet_group]
  cluster_identifier = var.cluster_identifier
  availability_zones = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  database_name      = var.db_name
  master_username    = var.master_username
  master_password    = var.master_password
  db_subnet_group_name = var.db_subnet_group
  engine             = "aurora-mysql"
  vpc_security_group_ids = [aws_security_group.db-sg.id]
  skip_final_snapshot = true
  backup_retention_period = 0
  apply_immediately = true
}

