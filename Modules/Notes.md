**Module** is a **container for multiple resources** that are used together. It allows you to *organize and encapsulate configurations*, promoting *reusability*, *maintainability*, and *simplicity* in infrastructure code.

Types of Modules:
- **Root Module:** This is the main configuration that Terraform uses when you run commands like `terraform apply`
- **Child Module:** Any module referenced by another module is considered a child module. These are reusable components that you can call from the root module or other modules.
- **Public Modules:** These are modules shared publicly (often in the Terraform Registry) for common tasks like creating VPCs, EC2 instances, etc.
- **Private Modules:** These are custom, internal modules that are used within your organization or project.

```hcl
# ./modules/vpc/main.tf

variable "cidr_block" {}

resource "aws_vpc" "main" {
  cidr_block = var.cidr_block
}
```

```hcl
# main.tf

module "vpc" {
  source = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
}
```

---

You have two Terraform modules:
- **Module A** provisions an S3 bucket.
- **Module B** provisions an EC2 instance and needs the S3 bucket name from Module A.

How can you ensure that the EC2 instance is created only after the S3 bucket is successfully provisioned, considering **Terraform’s dependency graph** and **implicit vs. explicit dependencies**?

**SOLUTION**

 Terraform automatically builds a *dependency graph*, meaning resources that depend on outputs from another resource will implicitly wait for that resource to be created first.
- In Module A, we define an output variable that exposes the S3 bucket name:
```hcl
output "s3_bucket_name" {
  value = aws_s3_bucket.example.bucket
}
```
- Inside Module B, define an input variable for the bucket name:
```hcl
variable "s3_bucket_name" {
  type = string
}

resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  tags = {
    Name       = "MyEC2Instance"
    S3_Bucket  = var.s3_bucket_name
  }
}
```
- In the root module, where both Module A and Module B are declared, we reference Module A’s output when calling Module B:
```hcl
module "s3_bucket" {
  source = "./modules/s3"
}

module "ec2_instance" {
  source         = "./modules/ec2"
  s3_bucket_name = module.s3_bucket.s3_bucket_name
}
```
- Terraform’s dependency graph automatically ensures that Module B only runs after Module A is successfully provisioned. However, if we need to enforce an explicit dependency, we can use the `depends_on` argument inside Module B, but that's generally not required when using *output-based dependencies*.
```hcl
resource "aws_instance" "example" {
  depends_on = [var.s3_bucket_name]  # Explicit dependency (optional)

  ami           = "ami-12345678"
  instance_type = "t2.micro"
}
```
- If the S3 bucket was manually created outside Terraform then we *shouldn't create it using Terraform again*. Instead, we can use a `data` source to fetch the existing bucket name:
```hcl
data "aws_s3_bucket" "existing_bucket" {
  bucket = "my-existing-bucket"
}

resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  tags = {
    Name       = "MyEC2Instance"
    S3_Bucket  = data.aws_s3_bucket.existing_bucket.id
  }
}
```
