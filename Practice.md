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
