output "vpc_id" {
  description = "THE ID of VPC"
  value = aws_vpc.this.id
}

output "subnet_a_id" {
  description = "THE ID of Subnet A"
  value = aws_subnet.subnet_a.id
}

output "subnet_b_id" {
  description = "THE ID of Subnet B"
  value = aws_subnet.subnet_b.id
}