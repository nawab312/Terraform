**Resource Dependencies**

In Terraform, resources often have dependencies on one another. For example, an EC2 instance might need a security group, or a database instance might require a VPC. Dependencies ensure that resources are created in the right order.

- *Implicit Dependencies* Terraform automatically creates dependencies between resources based on references. If a resource is referencing the output or attribute of another resource, Terraform understands that one depends on the other.
```hcl
resource "aws_vpc" "main" {
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet" {
  vpc_id = aws_vpc.main.id  # Implicit dependency
  cidr_block = "10.0.1.0/24"
}
```
Here, the aws_subnet resource depends on the aws_vpc resource because the subnet requires the vpc_id which is taken from the aws_vpc.main.id. Terraform automatically establishes the correct order of operations.

- *Explicit Dependencies* Use the `depends_on` argument to explicitly declare a dependency. This is useful when there is no natural reference between resources but an order still needs to be enforced.
```hcl
resource "aws_security_group" "example" {
  name = "example"
}https://github.com/nawab312/Terraform/blob/main/Advance_Terraform_Features/Notes.md

resource "aws_instance" "example" {
  ami = "ami-123456"
  instance_type = "t2.micro"
  depends_on = [aws_security_group.example]  # Explicit dependency
}
```
In this case, Terraform will ensure that the `aws_security_group` is created before the `aws_instance` is provisioned, even though the security group is not directly referenced in the `aws_instance` resource.

- *Resource Graph* Terraform builds an internal graph of resources. This graph helps determine the dependencies between resources. Terraform then uses this graph to apply resources in the correct order.

---

The **prevent_destroy** is a Terraform lifecycle rule that prevents accidental deletion of critical resources. When enabled, Terraform will fail if an attempt is made to destroy the resource.
```hcl
resource "aws_s3_bucket" "important_bucket" {
  bucket = "my-important-bucket"

  lifecycle {
    prevent_destroy = true
  }
}
```
- If someone tries to delete this S3 bucket using `terraform destroy` or if it's removed from the configuration, Terraform will fail with an error.

The **ignore_changes** is a Terraform lifecycle rule that allows Terraform to ignore changes to specific resource attributes that may be modified outside of Terraform (e.g., manually via the AWS console).
```hcl
resource "aws_instance" "web" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  lifecycle {
    ignore_changes = [instance_type]
  }
}
```
- Even if someone manually changes the `instance_type` in AWS, Terraform will ignore this difference in `terraform plan` or `terraform apply`.

*Example Scenarios*
- Ignore tags Updates
- Ignore desired_capacity in AWS Auto Scaling Group
- Ignore public_ip for EC2 Instances

The **create_before_destroy** lifecycle policy in Terraform is used to ensure that a new resource is created *before* the existing one is destroyed. This helps prevent downtime or disruptions in services when modifying resources. 
By default, Terraform follows a *destroy-then-create* approach when updating resources, which can cause downtime. The `create_before_destroy` policy changes this behavior to *create-then-destroy* ensuring:
- Zero downtime when replacing resources.
- Safer updates for production environments.

Not all resources support create_before_destroy.
```hcl
resource "aws_instance" "example" {
  ami           = "ami-12345678"
  instance_type = "t2.micro"

  lifecycle {
    create_before_destroy = true
  }
}
```
