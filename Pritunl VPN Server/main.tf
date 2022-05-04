
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
  profile = ""
  region  = "ap-south-1"
}

// Import VPC module to use outputs
module "myVPC" { // Run This module also
  source = "../VPC"
}

// Define Sg
resource "aws_security_group" "pritunl-sg" {
  name        = "Rahul-tf-Pritunl"
  description = "Allow HTTPS & SSH traffic"
  vpc_id      = module.myVPC.VPC_ID #"vpc-04a220b2e6d81a4d5"

  // Incoming Traffic
  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

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

// Using spot instances
resource "aws_spot_instance_request" "Pritnul_server" {
  ami = var.ami_type
  #spot_price             = "0.016"
  instance_type = var.instance_type
  #spot_type              = "one-time" // instance terminate after request closed
  instance_interruption_behavior = "stop"
  # block_duration_minutes = "120"
  wait_for_fulfillment = "true"
  key_name             = var.key_name
  security_groups      = ["${aws_security_group.pritunl-sg.id}"]
  subnet_id            = module.myVPC.Public_Subnet1_ID
  tags = {
    Name = var.tag
  }
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file("../../rahul_ec2.pem")
    host        = self.public_ip
  }

  provisioner "remote-exec" {
    inline = [
      "sudo apt update -y",
      "echo 'deb http://repo.pritunl.com/stable/apt focal main' | sudo tee /etc/apt/sources.list.d/pritunl.list",
      "sudo apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A",
      "echo 'deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse' | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list",
      "curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -",
      "sudo apt update -y",
      "sudo apt install -y mongodb-server",
      "sudo systemctl start mongodb",
      "sudo apt install pritunl -y",
      "sudo systemctl start pritunl",
      "sudo systemctl enable pritunl mongodb",
      "sudo pritunl setup-key",
      "sleep 60", //wait for DB setup
      "sudo pritunl default-password"
    ]
  }
 
}

// Define instance resources
# resource "aws_instance" "Pritnul_server" {
#   ami           = var.ami_type
#   instance_type = var.instance_type
#   key_name = var.key_name
#   subnet_id = module.myVPC.Public_Subnet1_ID #"subnet-0c63fb604c6c9c741"
#   vpc_security_group_ids = ["${aws_security_group.pritunl-sg.id}"]
#   tags = {
#     Name = var.tag
#   }
#   user_data = <<-EOF
#                 #! /bin/bash
#                 sudo su root
#                 apt update -y
#                 echo "deb http://repo.pritunl.com/stable/apt focal main" | tee /etc/apt/sources.list.d/pritunl.list
#                 apt-key adv --keyserver hkp://keyserver.ubuntu.com --recv 7568D9BB55FF9E5287D586017AE645C0CF8E292A
#                 echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/4.4 multiverse" | tee /etc/apt/sources.list.d/mongodb-org-4.4.list
#                 curl -fsSL https://www.mongodb.org/static/pgp/server-4.4.asc | apt-key add -
#                 apt update -y
#                 apt install pritunl -y
#                 apt install -y mongodb-server
#                 systemctl start pritunl
#                 systemctl start mongodb
#                 systemctl enable pritunl mongodb
#   EOF
# }


