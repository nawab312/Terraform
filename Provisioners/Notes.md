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

**Remote-exec Provisioner**
- Executes commands on a remote resource (like an EC2 instance) after it is created. This provisioner requires SSH or WinRM access to the resource.
- Often used for installing software, running configuration scripts, or performing system setup tasks on remote machines.

```hcl
resource "aws_instance" "example" {
  ami           = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"

  provisioner "remote-exec" {
    inline = [
      "sudo apt-get update",
      "sudo apt-get install -y nginx"
    ]

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/path/to/.pem")
      host        = self.public_ip
    }
  }
}
```

**File Provisioner**
- Uploads files or directories from the local machine to the remote resource. This is useful for copying configuration files, scripts, or assets to a resource after it has been created.

```hcl
resource "aws_instance" "example" {
  ami           = "ami-04b4f1a9cf54c11d0"
  instance_type = "t2.micro"

  provisioner "file" {
    source      = "./local_script.sh"
    destination = "/tmp/remote_script.sh"

    connection {
      type        = "ssh"
      user        = "ubuntu"
      private_key = file("/path/to/.pem")
      host        = self.public_ip
    }
  }
}
```

- **By default, Terraform fails the resource creation if a provisioner fails. If you want to ignore failures, you can use `on_failue = "continue"` :**

```hcl
provisioner "remote-exec" {
  on_failure = "continue"
  inline = ["some command"]
}
```
- You can ensure a provisioner runs only on the first apply and not during every Terraform execution using `when = create`

```hcl
provisioner "remote-exec" {
  on_failure = "continue"
  inline = ["some command"]
}
```

