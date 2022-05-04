
// Select terraform provider
terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }
  // To implement remote sharing and lock 
  // Create a s3 bucket and Dynamo DB table with PK as LockID
   backend "s3" {
    encrypt = true    
    bucket = "rahul-tf-state-file" // Stores remotely
    dynamodb_table = "rahul-tf-lock-dynamo"  // Implement Lock
    key    = "terraform.tfstate"
    region = "ap-south-1"
    profile = "squareops"
  }

  required_version = ">= 0.14.9"
}


// Define provider
provider "aws" {
  profile = ""
  region  = var.region
}

// Fetch AZs
data "aws_availability_zones" "available" {
  state = "available"
}

// VPC Module form registry
module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = var.vpc_name
  cidr = var.cidr_block_vpc

  azs             = [data.aws_availability_zones.available.names[0], data.aws_availability_zones.available.names[1]]
  private_subnets = [cidrsubnet(var.cidr_block_vpc, 8, 0), cidrsubnet(var.cidr_block_vpc, 8, 1)]
  public_subnets  = [cidrsubnet(var.cidr_block_vpc, 8, 2), cidrsubnet(var.cidr_block_vpc, 8, 3)]

  enable_nat_gateway = true
  single_nat_gateway = true
  one_nat_gateway_per_az = false

  #enable_vpn_gateway = true

  tags = {
    Name = var.tag_name
  }
}
