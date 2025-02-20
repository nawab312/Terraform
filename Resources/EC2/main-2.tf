provider "aws" {
    region = "us-east-1"
}

resource "aws_security_group" "AllowSSH" {
    name = "AllowSSH"
    description = "Allow SSH From any Machine"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "Example" {
    ami = "ami-04b4f1a9cf54c11d0"
    instance_type = "t2.micro"

    security_groups = [aws_security_group.AllowSSH.name]

    tags = {
      Name = "MyInstance"
    }
}
