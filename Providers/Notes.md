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

- The `terraform providers lock` command is useful to lock down the versions of the providers you are using in your configuration, preventing unexpected issues from newer provider releases and ensuring your Terraform setup is reproducible and consistent

```bash
terraform init

Initializing the backend...

Initializing provider plugins...
- Finding latest version of hashicorp/aws...
- Installing hashicorp/aws v5.88.0...
- Installed hashicorp/aws v5.88.0 (signed by HashiCorp)

Terraform has created a lock file .terraform.lock.hcl to record the provider
selections it made above. Include this file in your version control repository
so that Terraform can guarantee to make the same selections by default when
you run "terraform init" in the future.
```

```hcl
 This file is maintained automatically by "terraform init".
# Manual edits may be lost in future updates.

provider "registry.terraform.io/hashicorp/aws" {
  version = "5.88.0"
  hashes = [
    "h1:PXaP+z5Z9pcUUcJqS6ea09wR/cscBq1F9jRsNqe39rM=",
    "zh:24f852b1cca276d91f950cb7fb575cacc385f55edccf4beec1f611cdd7626cf5",
    "zh:2a3b3f5ac513f8d6448a31d9619f8a96e0597dd354459de3a4698e684c909f96",
    "zh:3700499885a8e0e532eccba3cb068340e411cf9e616bf8a59e815d3b62ca3e46",
    "zh:4aab3605468244a74cbde66784ea1d30dc0fc6caf26d1b099427ecd5790f7c4d",
    "zh:74eca9314d6dd80b215d7bc1c4be37d81e1045d625d5b512995f3a352d7a43bc",
    "zh:77d9a06c63a4ad615bc97f67f948250397267f15698ebb2547fbdd20f734983c",
    "zh:82d6aaef1eb0caf9ca451887fdbdcff10ab09318b1d60faa883a013283ab2b15",
    "zh:8dbcfb121b887ce8572f5ab8174d592a729390ca32dc5fdacac4c7c1c508411a",
    "zh:95d51e80b55ff9064f5c1bc61d78f992e2f89c986ba2b10546ea4461d35c24f9",
    "zh:9b12af85486a96aedd8d7984b0ff811a4b42e3d88dad1a3fb4c0b580d04fa425",
    "zh:9ead5de0e123020926a0edaf88d9eed5cb86afe438a875528f6d11d0d27eed73",
    "zh:ab7c940cbb2081314f4af3cdd61ed2c1d59fd7a60fa3db27770887d63072fbdd",
    "zh:d52cd68006fd6fa8d028cdf569a6620fbc31726019beb7c75affa8764622d398",
    "zh:f179ca86ad5d5fb88dfd8e8e7c448f2c0ad550d22152f939b8465baeaf9289e9",
    "zh:f54dda271fa6dfee06537066278669a3f92c872e7dfa5a0184cd9117f7e47b8c",
  ]
}
```

```bash
terraform providers lock
- Fetching hashicorp/aws 5.88.0 for linux_amd64...
- Retrieved hashicorp/aws 5.88.0 for linux_amd64 (signed by HashiCorp)
- Obtained hashicorp/aws checksums for linux_amd64; All checksums for this platform were already tracked in the lock file

Success! Terraform has validated the lock file and found no need for changes.
```
