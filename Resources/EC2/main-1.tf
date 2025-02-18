provider "aws" {
    region = "us-east-1"
}

resource "aws_security_group" "allow_ssh" {
    name = "allow_ssh"
    description = "allow_ssh_from_my_machine"

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "web" {
    ami = "ami-04b4f1a9cf54c11d0"
    instance_type = "t2.micro"
    key_name = "myKey"
    security_groups = [aws_security_group.allow_ssh.name]

    provisioner "remote-exec" {
        inline = [
            "sudo apt-get update -y",
            "sudo apt-get install apache2 -y",
            "sudo systemctl start apache2",
            "sudo systemctl enable apache2"
        ]

        connection {
            type = "ssh"
            user = "ubuntu"
            private_key = file("/home/siddharth312/Downloads/myKey.pem")
            host = aws_instance.web.public_ip
        }
    }

    tags = {
      Name = "ApacheWebServer"
    }

}
