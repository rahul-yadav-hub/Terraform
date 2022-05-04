
output "instance_public_ip" {
  description = "Public IP address of the EC2 instance"
  value       = aws_spot_instance_request.Pritnul_server.public_ip
}
