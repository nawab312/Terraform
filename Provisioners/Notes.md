- Provisioners are used to execute scripts or commands on resources after they are created or updated.
- Provisioners are typically used for tasks like setting up a server (e.g., installing software, configuring files), running a shell script, or performing actions on remote machines.

**local-exec Provisioner**
- Runs a command or script locally on the machine where Terraform is being executed (the local machine, not the target resource).
- Useful for tasks that need to be run on the local system, such as triggering a notification or creating a local file after resource creation.

```hcl
#main.tf

terraform {
  required_providers {
    aws = {
        source = "hashicorp/aws"
        version = "5.88.0"
    }
  }
}

resource "aws_instance" "example_instance" {
    ami = "ami-04b4f1a9cf54c11d0"
    instance_type = "t2.micro"

    provisioner "local-exec" {
        command = "echo 'Instance ID With ID: ${self.id}'"
    }
}
```

```bash
# terraform init
# terraform apply -auto-approve

...
aws_instance.example_instance: Creating...
aws_instance.example_instance: Still creating... [10s elapsed]
aws_instance.example_instance: Provisioning with 'local-exec'...
aws_instance.example_instance (local-exec): Executing: ["/bin/sh" "-c" "echo 'Instance ID With ID: i-0d2849b0c1307a334'"]
aws_instance.example_instance (local-exec): Instance ID With ID: i-0d2849b0c1307a334
aws_instance.example_instance: Creation complete after 19s [id=i-0d2849b0c1307a334]
```
