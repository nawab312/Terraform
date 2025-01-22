output "instance_public_ip" {
    description = "Public IP of EC2 Instance"
    value = aws_instance.example_ec2_instance.public_ip
}
