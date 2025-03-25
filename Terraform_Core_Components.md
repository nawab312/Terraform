
    Providers
    Resources
    Variables
    Outputs
    Data Sources
    Modules
    State Management (terraform.tfstate)

**Data Source**
- Data sources are used to query existing infrastructure in your cloud environment or external systems.
- Example: Retrieve the latest AMI for a specific operating system. Some common data sources: AWS AMI (`aws_ami`), VPC (`aws_vpc`), Subnets (`aws_subnet`), and IAM roles (`aws_iam_role`).
```hcl
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
```
- Retrieve an Existing AWS VPC
```hcl
data "aws_vpc" "default" {
  default = true
}

output "vpc_id" {
  value = data.aws_vpc.default.id
}
```
