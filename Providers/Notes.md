- **Provider** is a plugin responsible for interacting with an API of a service or platform
- Provider allows Terraform to manage infrastructure resources such as *cloud platforms (e.g., AWS, Azure, GCP)*, *DNS providers*, *version control systems*, and more
- Each provider defines resources and data sources that Terraform can use to create, update, and delete infrastructure.

```hcl
#providers.tf

terraform {
  required_providers {
    aws = {
      source = "hashicorp/aws"
      version = ">= 3.0"
    }
  }
}
```
