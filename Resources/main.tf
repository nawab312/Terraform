provider "aws" {
    region = "us-east-1"
}

resource "aws_instance" "example_ec2_instance" {
    ami = var.ami_id_var
    instance_type = var.instance_type_var
}
