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
