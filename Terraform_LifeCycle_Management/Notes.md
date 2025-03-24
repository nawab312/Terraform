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
