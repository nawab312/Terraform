
**for_each**

The for_each meta-argument in Terraform allows you to iterate over a map or a set of strings to create multiple resources dynamically.
```hcl
resource "aws_instance" "example" {
  for_each = {
    "server1" = "t2.micro"
    "server2" = "t2.small"
  }

  ami           = "ami-12345678"
  instance_type = each.value
  tags = {
    Name = each.key
  }
}
```

**for**
- Convert List to Uppercase
```hcl
variable "names" {
  default = ["server1", "server2", "server3"]
}

output "uppercase_names" {
  value = [for name in var.names : upper(name)]
}
```

- Modify Map Values
```hcl
variable "servers" {
  default = {
    "web"  = "t2.micro"
    "db"   = "t3.medium"
    "cache" = "m5.large"
  }
}

output "server_info" {
  value = { for name, type in var.servers : name => "${name} runs on ${type}" }
}
```
```json
#Output
{
  "web": "web runs on t2.micro",
  "db": "db runs on t3.medium",
  "cache": "cache runs on m5.large"
}
```

- Creating AWS Instances from an Object List
  - `for_each = { for server in var.servers : server.name => server }`
    - `server.name` becomes the key (e.g., "web1", "web2", "db1")
    - `server` (the entire object) becomes the value in the new map
    - Since for_each expects a map, this transformation allows Terraform to create an AWS instance for each object.
```hcl
variable "servers" {
  default = [
    { name = "web1", type = "t2.micro", env = "prod" },
    { name = "web2", type = "t2.small", env = "dev" },
    { name = "db1", type = "m5.large", env = "prod" }
  ]
}

resource "aws_instance" "example" {
  for_each = { for server in var.servers : server.name => server }

  ami           = "ami-12345678"
  instance_type = each.value.type

  tags = {
    Name = each.key
    Environment = each.value.env
  }
}
```
Input: List of Objects (`var.servers`)
```hcl
[
  { name = "web1", type = "t2.micro", env = "prod" },
  { name = "web2", type = "t2.small", env = "dev" },
  { name = "db1", type = "m5.large", env = "prod" }
]
```
`for` Expression Converts List to Map
```hcl
{
  "web1" = { name = "web1", type = "t2.micro", env = "prod" },
  "web2" = { name = "web2", type = "t2.small", env = "dev" },
  "db1"  = { name = "db1", type = "m5.large", env = "prod" }
}
```

You need to create a Terraform configuration that dynamically provisions multiple IAM users with different policies based on a list of users.
- Use a dynamic block to create IAM users from a given list.
- Assign different IAM policies based on user roles (e.g., Admin gets full access, Developer gets read-only access).
- Implement a conditional statement to create an IAM group only if the user count is greater than 5.

```hcl
provider "aws" {
  region = "us-east-1"
}

variable "users" {
  type = list(object({
    name = string
    role = string
  }))
  default = [
    { name = "alice", role = "Admin" },
    { name = "bob", role = "Developer" },
    { name = "charlie", role = "Developer" },
    { name = "dave", role = "Admin" },
    { name = "eve", role = "Developer" },
    { name = "frank", role = "Admin" }
  ]
}

# IAM Policy Attachments
data "aws_iam_policy" "admin" {
  name = "AdministratorAccess"
}

data "aws_iam_policy" "developer" {
  name = "ReadOnlyAccess"
}

# Create IAM Users
resource "aws_iam_user" "users" {
  for_each = { for user in var.users : user.name => user }
  name     = each.key
}

# Attach Policies Dynamically
resource "aws_iam_user_policy_attachment" "policy_attachment" {
  for_each   = { for user in var.users : user.name => user }
  user       = each.key
  policy_arn = each.value.role == "Admin" ? data.aws_iam_policy.admin.arn : data.aws_iam_policy.developer.arn
}

# Create IAM Group only if users count > 5
resource "aws_iam_group" "developers" {
  count = length(var.users) > 5 ? 1 : 0
  name  = "DevelopersGroup"
}

# Add Developer users to the IAM Group
resource "aws_iam_group_membership" "developer_group_membership" {
  count = length(var.users) > 5 ? 1 : 0
  name  = "dev-group-membership"
  group = aws_iam_group.developers[0].name

  users = [for user in var.users : user.name if user.role == "Developer"]
}
```

