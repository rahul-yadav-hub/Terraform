output "VPC_ID" {
  description = "ID of the our VPC"
  value       = aws_vpc.my_vpc.id
}

output "Public_Subnet1_ID" {
  description = "ID of our Public Subnet 1"
  value       = aws_subnet.my-public-subnet-1.id
}

output "Public_Subnet2_ID" {
  description = "ID of our Public Subnet 2"
  value       = aws_subnet.my-public-subnet-2.id
}

output "Private_Subnet1_ID" {
  description = "ID of our Private Subnet 1"
  value       = aws_subnet.my-private-subnet-1.id
}

output "Private_Subnet2_ID" {
  description = "ID of our Private Subnet 2"
  value       = aws_subnet.my-private-subnet-2.id
}