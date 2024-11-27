output "instance_id" {
  description = "ID of the created EC2 Instance"
  value = aws_instance.this.id
}