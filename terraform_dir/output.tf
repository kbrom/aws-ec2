output "instance_public_ip_address" {
  description = "instance public ip"
  value = aws_instance.amazon-linux2.public_ip
}
