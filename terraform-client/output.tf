output "public_ip" {
  value = aws_instance.landscape.public_ip
}

output "ec2_public_dns" {
  description = "Public DNS of the EC2 instance"
  value       = aws_instance.landscape.public_dns
}
