provider "aws" {
  region = "us-east-1"
}

data "aws_ami" "example" {
  most_recent = true
  owners = ["amazon"]

  filter {
    name = "name"
    values = ["amzn2-ami-hvm-*"]
  }
}

output "ami_id" {
  value = data.aws_ami.example.id
}

output "ami_name" {
  value = data.aws_ami.example.name
}

#Outputs:
#ami_id = "ami-0c104f6f4a5d9d1d5"
#ami_name = "amzn2-ami-hvm-2.0.20250201.0-x86_64-gp2"
