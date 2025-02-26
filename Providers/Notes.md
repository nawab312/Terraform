- **Provider** is a plugin responsible for interacting with an API of a service or platform
- Provider allows Terraform to manage infrastructure resources such as *cloud platforms (e.g., AWS, Azure, GCP)*, *DNS providers*, *version control systems*, and more
- Each provider defines resources and data sources that Terraform can use to create, update, and delete infrastructure. Like with AWS Provider we can create EC2 Instances

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

- Terraform allows you to use **multiple providers** in the same configuration.
```hcl
provider "aws" {
  region = "us-west-2"
}

provider "google" {
  project = "my-project"
  region  = "us-central1"
}
```

**Can providers be customized? For example, if a provider doesn’t have some functionality you need, is there a way to extend it?**
Terraform providers themselves can’t typically be extended directly by users, but they can be customized in a couple of ways. One way is through the use of *local-exec* or *remote-exec* provisioners. The community sometimes creates custom providers, or you can even build your own provider using the Go programming language

- The `terraform providers lock` command is useful to lock down the versions of the providers you are using in your configuration, preventing unexpected issues from newer provider releases and ensuring your Terraform setup is reproducible and consisten
