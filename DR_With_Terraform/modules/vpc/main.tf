resource "aws_vpc" "this" {
    cidr_block = var.cidr_block
    enable_dns_support = true
    enable_dns_hostnames = true
}

resource "aws_subnet" "subnet_a" {
    vpc_id = aws_vpc.this.id
    cidr_block = var.subnet_a_cidr
    availability_zone = var.az_a
    map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_b" {
    vpc_id = aws_vpc.this.id
    cidr_block = var.subnet_b_cidr
    availability_zone = var.az_b
    map_public_ip_on_launch = true
}

resource "aws_internet_gateway" "gateway" {
    vpc_id = aws_vpc.this.id
}
