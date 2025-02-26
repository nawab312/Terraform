- **Terraform:** Allows you to provision, manage, and version infrastructure resources (e.g., servers, databases, networks) using a declarative(you describe what you want, and Terraform figures out how to achieve it) configuration language called HCL (HashiCorp Configuration Language)
- **Terraform Providers:** https://github.com/nawab312/Terraform/blob/main/Providers/Notes.md
- **Resources:** Resources are the building blocks of your infrastructure in Terraform. Example: An EC2 instance, an S3 bucket, or a database.
- **Terraform State Management:** https://github.com/nawab312/Terraform/blob/main/State%20Management%20in%20Terraform/Notes.md

### Variables in Terraform ###
```hcl
#variables.tf

variable "region" {
  description = "AWS Region"
  type = String
  value = "us-east-1"  
}
```

```hcl
#main.tf

provider "region" {
  region = var.region  
}

```hcl
#terraform.tfvars

region = "us-west-2"
```

- **variables.tf** Define the variables and their properties.
- **terraform.tfvars** Specifies value for variables
- Use -var to override: `terraform apply -var="region=us-east-1"`
