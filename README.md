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
```

```hcl
#terraform.tfvars

region = "us-west-2"
```

- **variables.tf** Define the variables and their properties.
- **terraform.tfvars** Specifies value for variables
- Use -var to override: `terraform apply -var="region=us-east-1"`

### Outputs in Terraform ###
- Outputs allow you to display specific information after applying a Terraform configuration, such as the instance ID, public IP address, etc. Outputs can also be used to pass data between modules.
- Outputs can be marked as sensitive to hide their values in logs `sensitive = true`

```hcl
output "instance_id" {
  description = "The ID Of the Instance"
  value = aws_instance.example.id
}
```
**DataSource** https://github.com/nawab312/Terraform/blob/main/DataSources/Notes.md

### Resource Dependencies ###
In Terraform, resources often have dependencies on one another. For example, an EC2 instance might need a security group, or a database instance might require a VPC. Dependencies ensure that resources are created in the right order.

- **Implicit Dependencies** Terraform automatically creates dependencies between resources based on references. If a resource is referencing the output or attribute of another resource, Terraform understands that one depends on the other.
```hcl
resource "aws_vpc" "main" { Advanced Terraform Features

    Terraform Remote Backends (S3, Consul, etcd, Terraform Cloud)

    Terraform Import (terraform import <resource> <id>)

    Managing Long-Lived Resources (terraform taint, terraform untaint)

    Handling State Drift (terraform refresh, terraform apply -refresh-only)
  cidr_block = "10.0.0.0/16"
}

resource "aws_subnet" "subnet" {
  vpc_id = aws_vpc.main.id  # Implicit dependency
  cidr_block = "10.0.1.0/24"
}
```
Here, the aws_subnet resource depends on the aws_vpc resource because the subnet requires the vpc_id which is taken from the aws_vpc.main.id. Terraform automatically establishes the correct order of operations.

- **Explicit Dependencies** Use the `depends_on` argument to explicitly declare a dependency. This is useful when there is no natural reference between resources but an order still needs to be enforced.
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

- **Resource Graph** Terraform builds an internal graph of resources. This graph helps determine the dependencies between resources. Terraform then uses this graph to apply resources in the correct order.

### Terraform Core Components ###
- **Providers**
- **Resources**
- **Variables**
- **Outputs**
- **Data Sources**
- **Modules**
- **State Management (terraform.tfstate)**

### Terraform Modules ###
- **What are Modules?**
- **Creating and Using Modules**
- **Module Best Practices**
- **Public vs. Private Modules**
- **Terraform Registry for Modules**
- https://github.com/nawab312/Terraform/blob/main/Modules/Notes.md

### Terraform Lifecycle Management ####
- **Resource Lifecycle (create, update, delete)**
- **depends_on**
- **prevent_destroy, ignore_changes, create_before_destroy**
- **Handling Immutable Infrastructure**
- https://github.com/nawab312/Terraform/blob/main/Terraform_LifeCycle_Management/Notes.md

###  Advanced Terraform Features ###
- **Terraform Remote Backends (S3, Consul, etcd, Terraform Cloud)**
- **Terraform Import (terraform import <resource> <id>)**
- **Managing Long-Lived Resources (terraform taint, terraform untaint)**
- **Handling State Drift (terraform refresh, terraform apply -refresh-only)**
- **Terraform Performance Optimization**
- https://github.com/nawab312/Terraform/blob/main/Advance_Terraform_Features/Notes.md

### Terraform Functions, Expressions, Loops & Dynamic Blocks ###
- **Built-in Functions (length, join, lookup, etc.)**
- **Conditional Expressions (count, for_each, dynamic blocks)**
- **locals {} and Reusable Logic**
- **Using count vs. for_each**
- **Dynamic Blocks in Terraform**
- **Looping Over Maps and Lists**
- https://github.com/nawab312/Terraform/blob/main/Terraform_Functions_Expressions_Loops_Dynamic_Blocks.md


**Interview** : https://github.com/nawab312/Terraform/blob/main/Interview.md

