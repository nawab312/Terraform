
    Built-in Functions (length, join, lookup, etc.)
    Conditional Expressions (count, for_each, dynamic blocks)
    locals {} and Reusable Logic
    Using count vs. for_each
    Dynamic Blocks in Terraform
    Looping Over Maps and Lists

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

