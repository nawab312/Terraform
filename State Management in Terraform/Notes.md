** What is the Terraform State File?**
Terraform uses a **state file** to keep track of resources it manages. The state file is a local or remote file (usually named `terraform.tfstate`) that stores the current configuration of all the infrastructure resources that Terraform is responsible for managing. The state file is typically stored in **JSON** format
It contains the following key information: Resources, Outputs, Provider Information, Metadata


-  Terraform compares the state file with your current configuration to determine which changes need to be made to the infrastructure during `terraform apply`. The state file is also used during `terraform plan` to predict what changes will occur without actually applying them.
