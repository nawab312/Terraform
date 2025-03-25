
    Providers
    Resources
    Variables
    Outputs
    Data Sources
    Modules
    State Management (terraform.tfstate)

**Data Source**
- Data sources are used to query existing infrastructure in your cloud environment or external systems.
- Example: Retrieve the latest AMI for a specific operating system.
  - Why `aws_ami` Supports `filter {}`
    - The `aws_ami` data source retrieves Amazon Machine Images (AMIs), which have multiple properties that require filtering.
```hcl
data "aws_ami" "latest_amazon_linux" {
    most_recent = true
    owners = ["amazon"]
    filter {
        name = "name"
        values = ["amzn2-ami-hvm-*-x86_64-gp2"]
    }
}

output "ami_id" {
    value = data.aws_ami.latest_amazon_linux.id
}
```
- Retrieve an Existing AWS VPC
```hcl
data "aws_vpc" "default" {
  default = true
}
```
- Retrieve an Existing AWS IAM Policy
```hcl
data "aws_iam_policy" "admin" {
    name = "Administrator Access"
}
```
