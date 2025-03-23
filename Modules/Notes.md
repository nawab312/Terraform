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
