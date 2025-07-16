output "client_public_ip" {
  value = aws_instance.landscape_client.public_ip
}

output "client_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.landscape_client.public_dns
}
