
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

// Define resources
resource "aws_instance" "test_server" {
  ami           = "ami-0851b76e8b1bce90b"
  instance_type = "t3a.micro"

  tags = {
    Name = var.instance_tag
  }
}
