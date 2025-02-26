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
 
![Uploading image.png…]()

