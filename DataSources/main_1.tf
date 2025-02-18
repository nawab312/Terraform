provider "aws" {
    region = "us-east-1"
}

data "aws_ami" "latest_amazon_linux" {
  most_recent = true
  owners      = ["amazon"]
  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }
}


output "ami_id" {
    value = data.aws_ami.latest_amazon_linux.id
}


#Outputs:
#ami_id = "ami-0c104f6f4a5d9d1d5"
