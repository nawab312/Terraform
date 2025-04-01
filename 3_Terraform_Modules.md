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

---

**Question -> You are managing infrastructure for a large project using Terraform, and you have a requirement where a resource should only be created or modified if a certain condition is met. However, this condition is based on the output from another resource that is created in a different module, and this output might not always be available at the time of execution.
How would you handle this situation in Terraform? Specifically, how can you ensure that the resource is only created or modified when the output is available, and avoid errors during the plan or apply phase?**

- You want to create two EC2 instances. The second EC2 instance (`module_b`) should only be created if the first EC2 instance (`module_a`) is successfully created, and the second EC2 instance will use some output from the first instance.
- Use **depends_on** Argument

```hcl
# ./module_a/main.tf

terraform {
  required_providers {
    aws = {
        version = "5.88.0"
        source = "hashicorp/aws"
    }
  }
}

resource "aws_instance" "example_A" {
    ami = "ami-04b4f1a9cf54c11d0"
    instance_type = "t2.micro"

    tags = {
        Name = "EC2-Instance-A"
    }
}

output "instance_id" {
    value = aws_instance.example_A.id
}
```

```hcl
# ./module_b/main.tf

terraform {
  required_providers {
    aws = {
        version = "5.88.0"
        source = "hashicorp/aws"
    }
  }
}

variable "instance_id_from_A" {
    description = "EC2 Instance ID from Instance A"
    type = string
}

resource "aws_instance" "example_B" {
    ami = "ami-04b4f1a9cf54c11d0"
    instance_type = "t2.micro"

    tags = {
        Name = "EC2-Instance-B"
        SourceInstance = var.instance_id_from_A
    }
}
```

```hcl
#main.tf

module "module_a" {
    source = "./module_a"
}

module "module_b" {
    source = "./module_b"
    instance_id_from_A = module.module_a.instance_id
    depends_on = [ module.module_a ]
}
```

- In this root module:
  - `module_a` is called first, and it creates the EC2 instance.
  - `module_b` is called next, but it depends on the output from `module_a` (`module.module_a.instance_id`). This ensures that module_b won't execute until `module_a` has completed successfully.

![image](https://github.com/user-attachments/assets/5c5a8d96-9749-4bb9-8a96-0a9c47eed16b)




