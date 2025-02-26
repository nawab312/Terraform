terraform {
    required_providers {
      aws = {
        source = "hashicorp/aws"
        version = "5.88.0"
      }
    }
}

data "aws_ami" "latest_amazon_linux" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
}

output "ami_id" {
    value = data.aws_ami.latest_amazon_linux.id
}
