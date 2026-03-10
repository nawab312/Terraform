# Terraform Interview Mastery — Section 2: HCL — HashiCorp Configuration Language

---

## Table of Contents

- [2.1 Basic Syntax: Blocks, Arguments, Expressions](#21-basic-syntax-blocks-arguments-expressions)
- [2.2 terraform {} Block — Required Providers, Version Constraints](#22-terraform--block--required-providers-version-constraints)
- [2.3 resource Block — Anatomy and Lifecycle](#23-resource-block--anatomy-and-lifecycle)
- [2.4 variable Block — Types, Defaults, Validation](#24-variable-block--types-defaults-validation)
- [2.5 output Block — Exposing Values](#25-output-block--exposing-values)
- [2.6 locals Block — Local Values and Expressions](#26-locals-block--local-values-and-expressions)
- [2.7 data Block — Reading Existing Infrastructure](#27-data-block--reading-existing-infrastructure)
- [2.8 .tfvars and .tfvars.json Files](#28-tfvars-and-tfvarsjson-files)
- [How Section 2 Connects to the Rest of the Roadmap](#-how-section-2-connects-to-the-rest-of-the-roadmap)
- [Common Interview Questions on Section 2](#common-interview-questions-on-section-2)

---

## 2.1 Basic Syntax: Blocks, Arguments, Expressions

### What it is (simple terms)

HCL is the language you write Terraform configuration in. It is purpose-built
for infrastructure — human-readable, supports comments, handles complex data
types, and is designed so that even non-developers can read it. Every single
thing you write in a `.tf` file is composed of three primitives: **blocks**,
**arguments**, and **expressions**.

### Why it exists — the problem it solves

Before HCL, the alternatives were:

- **JSON** — machine-readable but painful to write by hand (no comments,
  verbose, easy to misplace a bracket)
- **YAML** — indentation-sensitive, subtle whitespace bugs
- **XML** — verbose and hostile
- **Real languages (Python/Go)** — powerful but require programming knowledge
  and shift the mental model from "describe infra" to "write code"

HCL sits in the sweet spot: it is more expressive than JSON/YAML, supports
comments and rich types, but is simpler than a full programming language. It is
also **graph-friendly** — because it is declarative, tools can analyze it
statically without executing it.

---

### The Three Primitives

#### 1. Blocks

A block is a container for configuration. It has a **type**, zero or more
**labels**, and a **body** wrapped in `{}`.

```hcl
# Anatomy of a block:
# <block_type> "<label_1>" "<label_2>" {
#   <body>
# }

# Block with no labels
terraform {
  required_version = ">= 1.5.0"
}

# Block with one label (type)
provider "aws" {
  region = "us-east-1"
}

# Block with two labels (type + name) — most common pattern
resource "aws_instance" "web_server" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
}

# Block types you will use:
# terraform   — global settings
# provider    — cloud provider configuration
# resource    — infrastructure object to manage
# data        — read-only query of existing infra
# variable    — input parameter
# output      — exported value
# locals      — computed local values
# module      — call a child module
```

#### 2. Arguments

Arguments assign values to names within a block body. The format is always
`<name> = <value>`.

```hcl
resource "aws_instance" "web" {
  # These are all arguments:
  ami               = "ami-0c55b159cbfafe1f0"  # string
  instance_type     = "t3.micro"               # string
  monitoring        = true                     # bool
  ebs_optimized     = false                    # bool
  root_block_device {                          # nested block (not an argument)
    volume_size = 20                           # number
    volume_type = "gp3"                        # string
  }
}
```

#### 3. Expressions

Expressions compute values. They can be literals, references, function calls,
conditionals, or for-expressions.

```hcl
locals {
  # Literal expressions
  literal_string  = "hello"
  literal_number  = 42
  literal_bool    = true
  literal_list    = ["a", "b", "c"]
  literal_map     = { key = "value" }

  # Reference expression — reference another resource's attribute
  instance_id     = aws_instance.web.id

  # Interpolation — embed expression inside a string
  bucket_name     = "my-app-${var.environment}-data"

  # Arithmetic
  total_instances = var.min_instances + var.max_instances

  # Conditional (ternary)
  instance_type   = var.environment == "prod" ? "t3.large" : "t3.micro"

  # Function call
  upper_env       = upper(var.environment)
  today           = formatdate("YYYY-MM-DD", timestamp())

  # For expression
  public_ips      = [for i in aws_instance.web : i.public_ip]
}
```

---

### Comments

```hcl
# This is a single-line comment (preferred style in HCL)

// This also works (C-style, less common)

/*
  This is a
  multi-line comment
*/
```

---

### File Structure and Naming Conventions

Terraform loads **all `.tf` files in a directory** and merges them.
Standard convention:

```
project/
├── main.tf          # Core resources — the primary entry point
├── variables.tf     # All variable declarations
├── outputs.tf       # All output declarations
├── locals.tf        # All locals (optional, can be in main.tf)
├── providers.tf     # Provider and terraform {} blocks
├── data.tf          # All data sources (optional)
├── terraform.tfvars # Variable values (not committed if contains secrets)
└── versions.tf      # terraform {} block with required_providers (some teams)
```

> ⚠️ There is no enforced structure — all `.tf` files in a directory are merged.
> The file names are purely convention, not requirements. Breaking things into
> named files is critical for readability at scale.

---

### Types in HCL

```hcl
# Primitive types
string_val = "hello"
number_val = 3.14
bool_val   = true

# Collection types
list_val   = ["a", "b", "c"]             # ordered, same type
set_val    = toset(["a", "b", "c"])       # unordered, unique, same type
map_val    = { name = "web", port = 80 }  # key-value, same value type

# Structural types
tuple_val  = ["web", 80, true]            # ordered, mixed types
object_val = {                            # named attributes, mixed types
  name    = "web"
  port    = 80
  enabled = true
}
```

---

### 🎤 Short Crisp Interview Answer

> "HCL is composed of three primitives: blocks, arguments, and expressions.
> Blocks are containers with a type and optional labels — like
> `resource "aws_instance" "web"`. Arguments are key-value assignments inside
> blocks. Expressions compute values — they can be literals, references to other
> resources, function calls, or conditionals. Terraform loads all `.tf` files in
> a directory simultaneously, so there is no single entry point — it is a merged
> flat namespace."

---

### 🔬 Deeper Answer

> "HCL is parsed by the `hcl2` library into an AST before Terraform processes
> it. The key design decision is that HCL separates structure (the
> block/argument grammar) from semantics (what each block type means). This lets
> Terraform — and other HashiCorp tools like Packer and Vault — all use HCL but
> with completely different block types and semantics. The expression evaluator
> handles references lazily, which is how Terraform can build a dependency graph
> from expressions like `aws_instance.web.id` — it knows this value depends on
> the `aws_instance.web` resource without executing anything."

---

### ⚠️ Gotchas

- **Argument vs nested block confusion** — `tags = {}` is an argument (it is a
  map). `root_block_device {}` is a nested block. They look similar but behave
  differently in modules and overrides. ⚠️
- **No `null` coercion** — assigning `null` to an argument tells Terraform to
  use the provider's default, not to set the value to a literal null string.
- **No ordering guarantee across files** — Terraform merges all `.tf` files.
  Two files defining the same resource name will error. This is a common mistake
  when copy-pasting.
- **String interpolation is not always needed** — use `name = var.environment`
  not `name = "${var.environment}"`. Only use interpolation when embedding a
  reference inside a longer string.

```hcl
# Wrong — unnecessary interpolation
name = "${var.environment}"

# Right — direct reference when it is the whole value
name = var.environment

# Right — interpolation only when mixing with a literal string
name = "myapp-${var.environment}-server"
```

---

## 2.2 `terraform {}` Block — Required Providers, Version Constraints

### What it is (simple terms)

The `terraform {}` block is the global configuration block for a Terraform
project. It defines which version of Terraform itself is required, which
provider plugins are needed and at what versions, and which backend to use for
state storage.

### Why it exists

Without version constraints:

- Your colleague runs `terraform init` three months later and gets a newer AWS
  provider that changed a resource's behavior
- CI pipeline and local machine use different Terraform binary versions and
  plan output differs
- Team grows, provider releases a breaking change, and everything mysteriously
  breaks

The `terraform {}` block pins the contract between your code and the tooling.

---

### Full Anatomy

```hcl
terraform {
  # ── 1. Terraform CLI version constraint ─────────────────────────
  required_version = ">= 1.5.0, < 2.0.0"

  # ── 2. Required providers ────────────────────────────────────────
  required_providers {
    aws = {
      source  = "hashicorp/aws"    # registry.terraform.io/hashicorp/aws
      version = "~> 5.0"          # >= 5.0.0, < 6.0.0
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = ">= 2.20.0"
    }
    datadog = {
      source  = "DataDog/datadog"  # third-party provider
      version = "~> 3.30"
    }
  }

  # ── 3. Backend configuration ─────────────────────────────────────
  backend "s3" {
    bucket         = "my-company-terraform-state"
    key            = "prod/us-east-1/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-state-lock"
    encrypt        = true
  }

  # ── 4. Experimental features (rare) ──────────────────────────────
  # experiments = [module_variable_optional_attrs]
}
```

---

### Version Constraint Operators — Know These Cold ⚠️

```hcl
# Exact version — fragile, avoid in most cases
version = "5.31.0"

# Greater than or equal
version = ">= 5.0.0"

# Greater than or equal AND less than
version = ">= 5.0.0, < 6.0.0"

# Pessimistic constraint operator (~>) — THE MOST IMPORTANT ONE ⚠️
# ~> 5.0    means >= 5.0.0, < 6.0.0   (allows minor and patch updates)
# ~> 5.31.0 means >= 5.31.0, < 5.32.0 (allows only patch updates)
version = "~> 5.0"

# NOT equal — uncommon
version = "!= 5.28.0"  # skip a specific broken version
```

**The `~>` operator explained visually:**

```
~> 5.0    →  [5.0.0 ... 5.999.999]   ← entire 5.x range
~> 5.31   →  [5.31.0 ... 5.999.999]  ← 5.31 and above but not 6.x
~> 5.31.0 →  [5.31.0 ... 5.31.999]   ← only 5.31.x patches
```

> ⚠️ The `~>` with a two-part version (`5.0`) is more permissive than with a
> three-part version (`5.0.0`). This trips up many candidates.

---

### Provider Source Address Anatomy

```
registry.terraform.io/hashicorp/aws
└─────────────────────┘└────────┘└─┘
      hostname          namespace type

# Shorthand (implied hostname = registry.terraform.io)
source = "hashicorp/aws"

# Third-party provider (explicit namespace)
source = "DataDog/datadog"
# expands to: registry.terraform.io/DataDog/datadog

# Private/internal provider (fully qualified)
source = "registry.mycompany.com/internal/myprovider"
```

---

### `required_version` vs `required_providers` version ⚠️

```hcl
terraform {
  required_version = ">= 1.5.0"   # This is the TERRAFORM CLI version
                                   # Checked against the binary you run

  required_providers {
    aws = {
      version = "~> 5.0"           # This is the PROVIDER PLUGIN version
                                   # Downloaded by terraform init
    }
  }
}
```

> ⚠️ These control different things. Mixing them up in an interview signals
> inexperience.

---

### Real-World Multi-Provider Example

```hcl
# providers.tf — production setup for an AWS app with DNS and monitoring
terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.31"
    }
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    datadog = {
      source  = "DataDog/datadog"
      version = "~> 3.30"
    }
    vault = {
      source  = "hashicorp/vault"
      version = "~> 3.20"
    }
  }

  backend "s3" {
    bucket         = "acme-terraform-state-prod"
    key            = "services/payment-api/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
    kms_key_id     = "arn:aws:kms:us-east-1:123456789012:key/mrk-abc123"
  }
}
```

---

### 🎤 Short Crisp Interview Answer

> "The `terraform {}` block is the global configuration block. It has three main
> jobs: `required_version` pins the Terraform CLI version to prevent binary
> version drift across the team, `required_providers` declares which provider
> plugins are needed and at what versions — using the `~>` pessimistic operator
> to allow patch updates but prevent breaking major upgrades, and the `backend`
> block determines where state is stored. All three together form a
> reproducibility contract for your codebase."

---

### ⚠️ Gotchas

- `~> 5.0` and `~> 5.0.0` are **not the same** — `~> 5.0` allows `5.1`,
  `5.2`, etc., while `~> 5.0.0` only allows `5.0.1`, `5.0.2`, etc. ⚠️
- The `backend` block **cannot use variables or expressions** — it is processed
  before the rest of HCL is evaluated. If you need dynamic backend config, use
  the `-backend-config` flag in CI. ⚠️
- `required_providers` is needed even if you configure the provider — without
  it, Terraform may download the wrong provider binary, defaulting to the
  hashicorp namespace.
- Changing the `backend` block requires `terraform init -migrate-state` — just
  editing the block and re-applying does nothing to move existing state.

---

## 2.3 `resource` Block — Anatomy and Lifecycle

### What it is (simple terms)

The `resource` block is the most important block in Terraform. It represents a
single infrastructure object — an EC2 instance, an S3 bucket, an IAM role, a
DNS record, a Kubernetes namespace — that Terraform creates, manages, and
tracks in state.

### Why it exists

Every managed piece of infrastructure needs a declaration. The `resource` block
is that declaration. It tells Terraform: *"this thing should exist, with these
properties, managed by this provider, and referred to by this name."*

---

### Full Anatomy

```hcl
# resource "<PROVIDER_TYPE>" "<LOCAL_NAME>" { }
#          └────────────────┘  └──────────┘
#          resource type          your name
#          (determined by         (used to reference
#           the provider)          this resource elsewhere)

resource "aws_instance" "web_server" {
  # ── Required arguments ───────────────────────────────────────────
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"

  # ── Optional arguments ───────────────────────────────────────────
  subnet_id              = aws_subnet.public.id       # implicit dependency ⚠️
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name               = var.key_pair_name
  iam_instance_profile   = aws_iam_instance_profile.web.name

  # ── Nested block ─────────────────────────────────────────────────
  root_block_device {
    volume_size           = 30
    volume_type           = "gp3"
    encrypted             = true
    delete_on_termination = true
  }

  # ── Tags ─────────────────────────────────────────────────────────
  tags = {
    Name        = "web-server-${var.environment}"
    Environment = var.environment
    ManagedBy   = "terraform"
    Team        = "platform"
  }

  # ── Meta-arguments (covered in Section 8) ────────────────────────
  count      = var.instance_count
  depends_on = [aws_internet_gateway.main]

  lifecycle {
    create_before_destroy = true
    prevent_destroy       = false
    ignore_changes        = [ami, tags["LastUpdated"]]
  }
}
```

---

### Resource Addressing — How to Reference Resources

```hcl
# Format: <resource_type>.<local_name>.<attribute>
aws_instance.web_server.id
aws_instance.web_server.public_ip
aws_instance.web_server.private_ip
aws_instance.web_server.arn

# With count — returns a list
aws_instance.web_server[0].id
aws_instance.web_server[*].id    # splat — all IDs as list

# With for_each — returns a map
aws_instance.web_server["prod"].id
```

---

### Resource Lifecycle — The Full CRUD Lifecycle ⚠️

Understanding exactly when Terraform creates, updates, or replaces a resource
is critical for interviews and production safety.

```
                    ┌─────────────┐
                    │  terraform  │
                    │    plan     │
                    └──────┬──────┘
                           │
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
    ┌─────────────┐ ┌────────────┐ ┌──────────────────┐
    │   CREATE    │ │   UPDATE   │ │     REPLACE      │
    │  (new res.) │ │ (in-place) │ │  (destroy+create)│
    │      +      │ │     ~      │ │       -/+        │
    └─────────────┘ └────────────┘ └──────────────────┘
```

**When does replacement happen?**

- When any attribute that has `ForceNew=true` in the provider schema is changed
- `ami` change on EC2 → ForceNew → replacement
- `bucket` name change on S3 → ForceNew → replacement
- `engine` change on RDS → ForceNew → replacement

```hcl
# This plan output signals REPLACEMENT — pay attention in code review
-/+ resource "aws_instance" "web" {
      ~ ami = "ami-old" -> "ami-new" # forces replacement
      # The (forces replacement) annotation tells you WHY
    }
```

---

### The `lifecycle` Block — Controlling Resource Behavior ⚠️

```hcl
resource "aws_instance" "web" {
  ami           = data.aws_ami.latest.id
  instance_type = "t3.micro"

  lifecycle {
    # ── 1. create_before_destroy ──────────────────────────────────
    # Default behavior: destroy old, then create new (causes downtime)
    # With this flag:   create new first, then destroy old (zero downtime)
    # USE CASE: EC2 behind ALB — swing traffic before destroying old one
    create_before_destroy = true

    # ── 2. prevent_destroy ───────────────────────────────────────
    # Prevents terraform destroy or any plan that would destroy this resource
    # USE CASE: production RDS, critical S3 bucket
    # ⚠️ This is a code-level guard, not an AWS-level guard
    prevent_destroy = true

    # ── 3. ignore_changes ─────────────────────────────────────────
    # Tell Terraform to ignore drift on specific attributes
    # USE CASE: ASG manages instance count, Terraform should not fight it
    # USE CASE: Deployment pipeline updates AMI, not Terraform
    ignore_changes = [
      ami,               # ignore AMI changes (managed by deployment pipeline)
      tags["LastDeploy"] # ignore specific tag key, not all tags
    ]

    # ── 4. replace_triggered_by (Terraform >= 1.2) ────────────────
    # Trigger replacement of THIS resource when another resource changes
    # USE CASE: Force EC2 re-creation when launch template version changes
    replace_triggered_by = [
      aws_launch_template.web.latest_version
    ]
  }
}
```

---

### `create_before_destroy` Propagation ⚠️

```hcl
# If resource A depends on resource B, and B has create_before_destroy = true,
# then A also implicitly needs create_before_destroy = true.
# Terraform handles this automatically in the graph.
# BUT: if a dependency makes this impossible (e.g., unique name constraint),
# Terraform will error. You need to use random suffixes in resource names.

resource "aws_security_group" "web" {
  name = "web-sg-${random_id.suffix.hex}"  # required for CBP to work

  lifecycle {
    create_before_destroy = true
  }
}

resource "random_id" "suffix" {
  byte_length = 4
}
```

---

### Implicit vs Explicit Dependencies ⚠️

```hcl
# IMPLICIT dependency — Terraform detects it from the reference
resource "aws_instance" "web" {
  subnet_id = aws_subnet.public.id   # Terraform knows: create subnet first
}

# EXPLICIT dependency — when there is no reference but order still matters
# USE CASE: EC2 needs internet access but does not reference the gateway directly
resource "aws_instance" "web" {
  ami           = "ami-abc123"
  instance_type = "t3.micro"

  depends_on = [aws_internet_gateway.main]
  # Even though there is no direct reference, we know the gateway must exist
}
```

> Use `depends_on` sparingly. It makes the dependency graph less clear and can
> cause unnecessary sequential execution. Only use it when the dependency is
> real but not expressible through attribute references.

---

### Real-World Production Resource — Full Example

```hcl
# Production RDS instance with all best practices
resource "aws_db_instance" "primary" {
  identifier        = "${var.app_name}-${var.environment}-postgres"
  engine            = "postgres"
  engine_version    = "15.4"
  instance_class    = var.db_instance_class
  allocated_storage = var.db_storage_gb
  storage_type      = "gp3"
  storage_encrypted = true
  kms_key_id        = aws_kms_key.rds.arn

  db_name  = var.db_name
  username = var.db_username
  password = random_password.db_password.result

  db_subnet_group_name   = aws_db_subnet_group.main.name
  vpc_security_group_ids = [aws_security_group.rds.id]
  multi_az               = var.environment == "prod" ? true : false

  backup_retention_period   = 7
  backup_window             = "03:00-04:00"
  maintenance_window        = "sun:04:00-sun:05:00"

  deletion_protection       = true
  skip_final_snapshot       = false
  final_snapshot_identifier = "${var.app_name}-${var.environment}-final"

  tags = local.common_tags

  lifecycle {
    prevent_destroy = true        # Cannot accidentally destroy prod DB
    ignore_changes  = [password]  # Password rotated externally via Secrets Manager
  }
}
```

---

### 🎤 Short Crisp Interview Answer

> "The `resource` block declares a managed infrastructure object. Its type comes
> from the provider — `aws_instance`, `google_compute_instance`, etc. — and the
> local name is what you use to reference it in other expressions. The
> `lifecycle` block is the most important sub-block: `create_before_destroy`
> prevents downtime during replacements, `prevent_destroy` guards critical
> resources from accidental deletion, and `ignore_changes` tells Terraform to
> stop managing specific attributes — critical when external systems like
> auto-scaling also manage the same resource."

---

### ⚠️ Gotchas

- `prevent_destroy = true` is **code-level only** — it is a Terraform guard,
  not an AWS guard. If someone deletes the `lifecycle` block and re-applies,
  the protection disappears. For real protection, use AWS deletion protection
  plus resource policies.
- `ignore_changes = all` exists but is dangerous — Terraform stops tracking
  that resource entirely. It becomes a fire-and-forget resource.
- `create_before_destroy` can fail if the resource requires a unique name —
  you need randomized or timestamped names to make it work.
- `depends_on` on a module (not just a resource) causes Terraform to treat the
  **entire module** as a dependency, often creating unnecessary sequential
  chains.

---

## 2.4 `variable` Block — Types, Defaults, Validation

### What it is (simple terms)

Variables are the parameters of your Terraform module. They let you write
reusable configuration where the specific values — environment names, instance
sizes, CIDR ranges — are supplied at runtime rather than hard-coded.

### Why it exists

Without variables, every environment (dev/staging/prod) would need entirely
separate `.tf` files. Variables let you write the logic once and parameterize
the differences.

---

### Full Anatomy

```hcl
variable "environment" {
  # ── Type constraint ───────────────────────────────────────────────
  type = string

  # ── Description ───────────────────────────────────────────────────
  description = "Deployment environment (dev, staging, prod)"

  # ── Default value ─────────────────────────────────────────────────
  # If omitted, Terraform will prompt interactively or error in CI
  default = "dev"

  # ── Sensitive flag ────────────────────────────────────────────────
  # Redacts value from plan output and logs
  # Does NOT encrypt in state ⚠️
  sensitive = true

  # ── Validation block ──────────────────────────────────────────────
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be one of: dev, staging, prod."
  }
}
```

---

### All Variable Types

```hcl
# ── Primitive types ────────────────────────────────────────────────

variable "app_name" {
  type    = string
  default = "myapp"
}

variable "replica_count" {
  type    = number
  default = 3
}

variable "enable_monitoring" {
  type    = bool
  default = true
}

# ── Collection types ───────────────────────────────────────────────

variable "availability_zones" {
  type    = list(string)
  default = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "allowed_ports" {
  type    = list(number)
  default = [80, 443, 8080]
}

variable "tags" {
  type = map(string)
  default = {
    ManagedBy = "terraform"
    Team      = "platform"
  }
}

# ── Structural types ───────────────────────────────────────────────

variable "database_config" {
  type = object({
    instance_class    = string
    allocated_storage = number
    multi_az          = bool
    engine_version    = string
  })
  default = {
    instance_class    = "db.t3.micro"
    allocated_storage = 20
    multi_az          = false
    engine_version    = "15.4"
  }
}

variable "allowed_cidrs" {
  type    = set(string)      # like list but unordered and unique
  default = ["10.0.0.0/8", "172.16.0.0/12"]
}

# tuple — ordered, mixed types (less common)
variable "app_config" {
  type    = tuple([string, number, bool])
  default = ["myapp", 8080, true]
}

# ── any — escape hatch, use sparingly ⚠️ ──────────────────────────
variable "flexible_config" {
  type    = any
  default = {}
}
```

---

### Validation Blocks — Multiple Conditions

```hcl
variable "instance_type" {
  type        = string
  description = "EC2 instance type"

  validation {
    condition     = can(regex("^t3\\.", var.instance_type))
    error_message = "Only t3 family instances are allowed for cost reasons."
  }

  validation {
    condition     = !contains(["t3.nano", "t3.micro"], var.instance_type)
    error_message = "t3.nano and t3.micro are too small for this workload."
  }
}

variable "vpc_cidr" {
  type        = string
  description = "VPC CIDR block"

  validation {
    # can() returns true if the expression succeeds without error
    condition     = can(cidrnetmask(var.vpc_cidr))
    error_message = "vpc_cidr must be a valid IPv4 CIDR block."
  }
}

variable "retention_days" {
  type = number
  validation {
    condition     = var.retention_days >= 7 && var.retention_days <= 365
    error_message = "retention_days must be between 7 and 365."
  }
}
```

---

### Variable Precedence Order ⚠️ (Heavily Tested)

Terraform resolves variables in this order.
**Later sources override earlier ones.**

```
1. Default value in variable {} block              ← lowest priority
2. terraform.tfvars file (auto-loaded)
3. terraform.tfvars.json file (auto-loaded)
4. *.auto.tfvars files (auto-loaded, alphabetical)
5. *.auto.tfvars.json files (auto-loaded, alphabetical)
6. -var-file="custom.tfvars" flag (in order specified)
7. -var="key=value" CLI flag                        ← highest priority
8. TF_VAR_<name> environment variables              ← same level as -var
```

```bash
# Practical example:
# terraform.tfvars sets environment = "dev"
# CI pipeline overrides with:
terraform plan \
  -var-file="prod.tfvars" \
  -var="environment=prod"
# -var flag wins over -var-file
```

> ⚠️ `TF_VAR_` env vars and `-var` CLI flags have the **same precedence level**.
> If both are set for the same variable, the behavior is technically undefined.
> Never rely on both being set simultaneously.

---

### Sensitive Variables ⚠️

```hcl
variable "db_password" {
  type      = string
  sensitive = true
}
```

**What `sensitive = true` DOES:**
- Redacts the value in `terraform plan` and `terraform apply` output
  (shows `(sensitive value)`)
- Prevents it from appearing in standard log output

**What it does NOT do:** ⚠️

- Does **not** encrypt the value in the state file — stored in plaintext
- Does **not** prevent the value from being passed to child modules
- Does **not** prevent it from appearing in provider debug logs

```hcl
# The value IS in the state file regardless of sensitive = true
# This is why state file security is critical (covered in Section 6)

# Better pattern: use data sources instead of variables for secrets
data "aws_secretsmanager_secret_version" "db_password" {
  secret_id = "prod/myapp/db-password"
}

resource "aws_db_instance" "main" {
  password = data.aws_secretsmanager_secret_version.db_password.secret_string
  # Still ends up in state, but at least it is not in your .tfvars
}
```

---

### Optional Object Attributes (Terraform >= 1.3)

```hcl
variable "server_config" {
  type = object({
    instance_type = string
    disk_size_gb  = optional(number, 30)    # optional with default
    enable_backup = optional(bool, true)    # optional with default
    extra_tags    = optional(map(string), {})
  })
}

# Caller only needs to provide required fields:
server_config = {
  instance_type = "t3.medium"
  # disk_size_gb  defaults to 30
  # enable_backup defaults to true
}
```

---

### 🎤 Short Crisp Interview Answer

> "Variable blocks define the inputs to a Terraform module. They support
> primitive types — string, number, bool — and complex types like list, map,
> set, and object. The `validation` block lets you enforce constraints at plan
> time with a condition expression and an error message. The precedence order
> matters in CI/CD: defaults are lowest, then tfvars files, then `-var-file`
> flags, then `-var` CLI flags which are highest. One critical gotcha:
> `sensitive = true` only redacts the value from CLI output — it does NOT
> prevent the value from being stored in plaintext in the state file."

---

### ⚠️ Gotchas

- **`type = any`** disables type checking — the caller can pass anything.
  Use only for true pass-through variables in wrapper modules.
- Variables with **no default and no value provided** cause Terraform to
  interactively prompt in local runs and **fail in CI** — this is a pipeline
  gotcha if you do not manage all variable sources.
- `object()` type validation is **structural** — extra keys provided by the
  caller are **silently ignored**.
- `list(string)` vs `set(string)` — sets are unordered and deduplicate. If
  you use `for_each` with a list, you need to convert it to a set or map
  first. ⚠️

---

## 2.5 `output` Block — Exposing Values

### What it is (simple terms)

Output blocks expose values from your Terraform configuration. They serve two
purposes: printing useful information to the terminal after `apply` (like an IP
address or URL), and exposing values to **parent modules or other Terraform
configurations** via `terraform_remote_state`.

### Why it exists

Without outputs, Terraform configurations are black boxes. After you create an
EC2 instance, how does your application pipeline know its IP? After you create
an RDS instance, how does your app module know the endpoint? Outputs are the
answer.

---

### Full Anatomy

```hcl
output "instance_public_ip" {
  # ── The value to expose ──────────────────────────────────────────
  value = aws_instance.web.public_ip

  # ── Description (good practice for modules) ──────────────────────
  description = "Public IP address of the web server"

  # ── Sensitive output ─────────────────────────────────────────────
  sensitive = true   # redacts from terminal output, still readable via state

  # ── Depends on (rarely needed) ───────────────────────────────────
  depends_on = [aws_route53_record.web]
}
```

---

### Common Output Patterns

```hcl
# ── Primitive value ───────────────────────────────────────────────
output "vpc_id" {
  value       = aws_vpc.main.id
  description = "ID of the main VPC"
}

# ── Computed string ───────────────────────────────────────────────
output "rds_endpoint" {
  value       = "postgresql://${aws_db_instance.main.endpoint}/${var.db_name}"
  description = "Full PostgreSQL connection string"
  sensitive   = true
}

# ── List output ───────────────────────────────────────────────────
output "private_subnet_ids" {
  value       = aws_subnet.private[*].id
  description = "IDs of all private subnets"
}

# ── Map output ────────────────────────────────────────────────────
output "alb_dns_names" {
  value = {
    for k, v in aws_lb.services :
    k => v.dns_name
  }
  description = "Map of service name to ALB DNS name"
}

# ── Object output (useful for module consumers) ───────────────────
output "database" {
  value = {
    endpoint = aws_db_instance.main.endpoint
    port     = aws_db_instance.main.port
    name     = aws_db_instance.main.db_name
    username = aws_db_instance.main.username
  }
  sensitive   = true
  description = "Database connection details"
}
```

---

### Outputs in Modules — The Core Use Case ⚠️

```hcl
# modules/networking/outputs.tf
output "vpc_id" {
  value = aws_vpc.main.id
}

output "private_subnet_ids" {
  value = aws_subnet.private[*].id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}
```

```hcl
# root module main.tf — consuming the module outputs
module "networking" {
  source      = "./modules/networking"
  environment = var.environment
  cidr_block  = "10.0.0.0/16"
}

module "compute" {
  source             = "./modules/compute"
  vpc_id             = module.networking.vpc_id              # module output ref
  private_subnet_ids = module.networking.private_subnet_ids  # module output ref
}
```

---

### Querying Outputs After Apply

```bash
# Show all outputs
terraform output

# Show specific output
terraform output vpc_id

# JSON format (useful in CI/CD scripts)
terraform output -json

# Raw value (no quotes, useful for scripting)
terraform output -raw rds_endpoint

# Read a sensitive output (requires explicit intent)
terraform output -raw db_password
```

---

### Cross-Stack Output Consumption via `terraform_remote_state`

```hcl
# In the consuming stack (app layer reading networking layer outputs)
data "terraform_remote_state" "networking" {
  backend = "s3"
  config = {
    bucket = "acme-terraform-state"
    key    = "networking/terraform.tfstate"
    region = "us-east-1"
  }
}

# Use it like any other data source
resource "aws_instance" "app" {
  subnet_id = data.terraform_remote_state.networking.outputs.private_subnet_ids[0]
  vpc_security_group_ids = [
    data.terraform_remote_state.networking.outputs.app_security_group_id
  ]
}
```

> ⚠️ `terraform_remote_state` creates **tight coupling** between stacks. The
> consuming stack now depends on all the outputs being present in the remote
> state. If the networking team renames an output, the app stack breaks.
> Some teams use **SSM Parameter Store** or **Consul** as a looser coupling
> mechanism instead.

---

### 🎤 Short Crisp Interview Answer

> "Output blocks serve two purposes: displaying useful information after apply
> — like an IP or endpoint — and exposing values to parent modules or other
> configurations via `terraform_remote_state`. In module design, outputs are
> the public API of the module — you never reference child module resources
> directly, only their outputs. `sensitive = true` on an output redacts it from
> terminal display but the value is still accessible via `terraform output -raw`
> and is present in the state file."

---

### ⚠️ Gotchas

- Outputs are **only evaluated on apply**, not on plan for root modules.
  In child modules they are computed during plan.
- **You cannot reference an output directly** in the same module that defines
  it — you reference the resource attribute. The output is for *consumers*, not
  for internal use.
- If a module output references a `sensitive` resource attribute, Terraform will
  **force that output to be sensitive** automatically and warn you if you have
  not marked it explicitly. ⚠️
- Removing an output that another stack consumes via `terraform_remote_state`
  will break that consuming stack on next apply.

---

## 2.6 `locals` Block — Local Values and Expressions

### What it is (simple terms)

Locals let you define named expressions within a module that are computed once
and reused. Think of them as constants or computed variables — they cannot be
set from outside the module (unlike `variable`), and they do not produce
external output (unlike `output`). They are for internal DRY
(Don't Repeat Yourself) logic.

### Why it exists

Without locals, you end up with:

- Duplicated long expressions repeated in every resource
- Tag maps copy-pasted across 20 resources
- Conditional logic embedded deep in resource arguments making them unreadable

---

### Full Anatomy

```hcl
locals {
  # ── Simple computed value ──────────────────────────────────────
  app_prefix = "${var.app_name}-${var.environment}"

  # ── Conditional ───────────────────────────────────────────────
  is_production = var.environment == "prod"

  # ── Common tags — the most universal use case ─────────────────
  common_tags = {
    Application = var.app_name
    Environment = var.environment
    ManagedBy   = "terraform"
    Team        = var.team_name
    CostCenter  = var.cost_center
    Repo        = "github.com/acme/${var.app_name}"
  }

  # ── Merging base tags with resource-specific tags ─────────────
  web_tags = merge(local.common_tags, {
    Role = "web-server"
    Tier = "frontend"
  })

  # ── Computed from data sources ────────────────────────────────
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name

  # ── Conditional instance type ─────────────────────────────────
  instance_type = local.is_production ? "t3.large" : "t3.micro"

  # ── List/map transformation ───────────────────────────────────
  azs = slice(data.aws_availability_zones.available.names, 0, 3)

  # ── For expression building a map ─────────────────────────────
  subnet_map = {
    for idx, az in local.azs :
    az => cidrsubnet(var.vpc_cidr, 4, idx)
  }
}
```

---

### Real-World Production Locals Pattern

```hcl
# locals.tf — production naming and tagging strategy
locals {
  # ── Naming prefix for all resources ──────────────────────────────
  name_prefix = lower(
    "${var.org_name}-${var.app_name}-${var.environment}-${var.region_code}"
  )

  # ── Environment-based sizing ──────────────────────────────────────
  env_config = {
    dev = {
      instance_type  = "t3.micro"
      min_capacity   = 1
      max_capacity   = 2
      multi_az       = false
      retention_days = 7
    }
    staging = {
      instance_type  = "t3.small"
      min_capacity   = 1
      max_capacity   = 4
      multi_az       = false
      retention_days = 14
    }
    prod = {
      instance_type  = "t3.medium"
      min_capacity   = 2
      max_capacity   = 20
      multi_az       = true
      retention_days = 90
    }
  }

  # ── Lookup current environment config ─────────────────────────────
  current_config = local.env_config[var.environment]

  # ── Common tags applied to all resources ──────────────────────────
  common_tags = {
    Application   = var.app_name
    Environment   = var.environment
    ManagedBy     = "terraform"
    TerraformRepo = var.repo_url
    Owner         = var.team_email
    CreatedDate   = formatdate("YYYY-MM-DD", timestamp())
  }
}
```

```hcl
# main.tf — using the locals
resource "aws_instance" "web" {
  instance_type = local.current_config.instance_type
  tags          = merge(local.common_tags, { Name = "${local.name_prefix}-web" })
}

resource "aws_db_instance" "main" {
  instance_class          = "db.${local.current_config.instance_type}"
  multi_az                = local.current_config.multi_az
  backup_retention_period = local.current_config.retention_days
  tags = merge(local.common_tags, { Name = "${local.name_prefix}-db" })
}
```

---

### `locals` vs `variable` — When to Use Which

```
Use variable when:                      Use locals when:
──────────────────────────────────────  ──────────────────────────────────────
Value comes from outside the module     Value is computed inside the module
Caller needs to customize it            It is an internal implementation detail
It is an input parameter                It is a named expression for DRY code
It can vary per environment             It derives from other values/variables
```

---

### ⚠️ Locals Limitations

```hcl
# Locals CANNOT be recursive — this is an error:
locals {
  a = local.b  # circular: a depends on b
  b = local.a  # circular: b depends on a
}

# Locals ARE evaluated lazily — only used locals are evaluated
# Unused locals do not cause errors (but tflint will warn about them)

# ⚠️ timestamp() in locals is re-evaluated on EVERY plan
# Tags with timestamps cause perpetual drift:
locals {
  # BAD — causes permanent drift because timestamp changes every plan run
  common_tags = {
    CreatedAt = timestamp()
  }
}

# BETTER — use ignore_changes to suppress the drift
resource "aws_instance" "web" {
  tags = local.common_tags
  lifecycle {
    ignore_changes = [tags["CreatedAt"]]
  }
}
```

---

### 🎤 Short Crisp Interview Answer

> "Locals are named computed expressions internal to a module — they cannot be
> set from outside like variables, and they do not expose values like outputs.
> Their primary use cases are DRY: defining a common tags map once and merging
> it into every resource, computing a name prefix from multiple variables, and
> defining environment-based configuration lookups that multiple resources
> consume. They are especially valuable for tag management at scale — define
> `local.common_tags` once, merge it everywhere."

---

### ⚠️ Gotchas

- `timestamp()` in locals re-evaluates on every plan — using it in tags creates
  **permanent drift** unless you add `ignore_changes` on that tag.
- There is no `local` (singular) block — it is always `locals` (plural). You
  can have multiple `locals` blocks in a file — they all merge into one
  namespace. ⚠️
- Locals cannot be circular — Terraform will error with a dependency cycle
  message.
- Complicated nested locals that reference each other deeply can make debugging
  hard — keep them shallow and readable.

---

## 2.7 `data` Block — Reading Existing Infrastructure

### What it is (simple terms)

Data sources let Terraform **query existing infrastructure** without managing
it. Unlike `resource` blocks which create and own what they declare, `data`
blocks are read-only — they fetch information about something that already
exists, either created outside of Terraform or in a different Terraform
configuration.

### Why it exists

Real infrastructure does not start from zero. You need to:

- Reference an AMI that AWS publishes (you do not manage AMIs, you use them)
- Look up a VPC created by another team's Terraform stack
- Get the current AWS account ID and region dynamically
- Read a secret from Secrets Manager
- Find the latest EKS-optimized AMI for a given Kubernetes version

---

### Full Anatomy

```hcl
# data "<provider_type>" "<local_name>" { }

data "aws_ami" "ubuntu_latest" {
  most_recent = true
  owners      = ["099720109477"]  # Canonical's AWS account ID

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Reference it:
resource "aws_instance" "web" {
  ami           = data.aws_ami.ubuntu_latest.id  # data source reference
  instance_type = "t3.micro"
}
```

---

### Most Important Data Sources to Know

```hcl
# ── 1. Current AWS identity (always useful) ───────────────────────
data "aws_caller_identity" "current" {}

data "aws_region" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
  azs        = data.aws_availability_zones.available.names
}

# ARN construction — no need to hard-code account IDs
resource "aws_iam_role_policy_attachment" "web" {
  role       = aws_iam_role.web.name
  policy_arn = "arn:aws:iam::${data.aws_caller_identity.current.account_id}:policy/MyPolicy"
}
```

```hcl
# ── 2. Look up an existing VPC (created by another team) ─────────
data "aws_vpc" "shared" {
  tags = {
    Name        = "shared-services-vpc"
    Environment = var.environment
  }
}

data "aws_subnets" "private" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.shared.id]
  }
  tags = {
    Tier = "private"
  }
}
```

```hcl
# ── 3. Latest EKS-optimized AMI via SSM ──────────────────────────
data "aws_ssm_parameter" "eks_ami" {
  name = "/aws/service/eks/optimized-ami/${var.k8s_version}/amazon-linux-2/recommended/image_id"
}
```

```hcl
# ── 4. IAM policy document (avoid heredoc JSON) ───────────────────
data "aws_iam_policy_document" "assume_role" {
  statement {
    effect  = "Allow"
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["ec2.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "web" {
  name               = "${local.name_prefix}-web-role"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}
```

```hcl
# ── 5. Read a secret from Secrets Manager ────────────────────────
data "aws_secretsmanager_secret_version" "db_creds" {
  secret_id = "prod/myapp/db-credentials"
}

locals {
  db_creds = jsondecode(
    data.aws_secretsmanager_secret_version.db_creds.secret_string
  )
}

resource "aws_db_instance" "main" {
  username = local.db_creds.username
  password = local.db_creds.password
}
```

```hcl
# ── 6. Remote state (reading another Terraform stack's outputs) ───
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "acme-terraform-state"
    key    = "infra/networking/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_instance" "app" {
  subnet_id = data.terraform_remote_state.network.outputs.private_subnet_ids[0]
}
```

---

### Data Sources vs Resources — Key Differences ⚠️

```
                  resource {}             data {}
────────────────────────────────────────────────────────────
Creates infra?    YES                     NO — read only
In state?         YES — tracked           YES — cached but not owned
Destroyed?        YES — on destroy        NO — never destroyed by Terraform
Prefix in refs?   aws_instance.web.id     data.aws_instance.web.id
Plan symbol?      + / ~ / -               read during refresh/plan
Lifecycle block?  Supported               NOT supported
```

---

### When Data Sources Are Evaluated ⚠️

```
During plan:
  Data sources with NO dependency on resources  → read immediately during plan
  Data sources that DEPEND on resources         → deferred to apply time
                                                  (shown as "known after apply")
```

```hcl
# This is read DURING PLAN — VPC already exists, no resource dependency
data "aws_vpc" "shared" {
  tags = { Name = "shared-services" }
}

# This is DEFERRED — depends on a resource being created in this same apply
resource "aws_vpc" "new" {
  cidr_block = "10.0.0.0/16"
}

data "aws_subnet" "in_new_vpc" {
  vpc_id = aws_vpc.new.id    # depends on resource being created
  # Shows as "(known after apply)" in plan output
}
```

---

### 🎤 Short Crisp Interview Answer

> "Data sources are read-only queries against existing infrastructure. You use
> them to reference things Terraform does not own — an AWS-published AMI, a VPC
> built by another team, the current account ID, or secrets in Secrets Manager.
> The key distinction from `resource` blocks is that Terraform never creates,
> updates, or destroys what a data source references — it only reads it. Data
> sources with no resource dependencies are read during plan; those that depend
> on resources being created are deferred to apply time."

---

### ⚠️ Gotchas

- **Data source reads fail the whole plan** if the thing does not exist yet.
  If you reference `data.aws_vpc.shared` and that VPC has not been created,
  `plan` fails. Common in bootstrapping scenarios. ⚠️
- Data sources **are cached in state** — they re-read every plan by default.
  If the underlying resource changes between plans, the data source value
  updates automatically.
- `data.aws_iam_policy_document` makes **no API calls** — it is a local-only
  computation by the AWS provider that produces a JSON IAM policy string.
  Use it instead of heredoc JSON. ⚠️
- `most_recent = true` in `aws_ami` — if you omit it and multiple AMIs match
  your filter, Terraform errors. This is a common gotcha with AMI data
  sources.

---

## 2.8 `.tfvars` and `.tfvars.json` Files

### What it is (simple terms)

`.tfvars` files are value assignment files — they provide values for input
variables without modifying the variable declarations themselves. Think of them
as environment-specific configuration files that you swap depending on whether
you are deploying to dev, staging, or prod.

### Why it exists

Variables declared in `.tf` files define the *shape* of inputs. `.tfvars`
files provide the *actual values*. This separation lets you:

- Keep sensitive values out of version control
- Have different values per environment without branching your infrastructure
  code
- Override defaults cleanly in CI/CD pipelines

---

### Formats

```hcl
# ── terraform.tfvars (HCL format, auto-loaded) ────────────────────

environment    = "prod"
app_name       = "payment-api"
region         = "us-east-1"
instance_type  = "t3.large"
replica_count  = 3
enable_backups = true

availability_zones = ["us-east-1a", "us-east-1b", "us-east-1c"]

tags = {
  Team       = "platform"
  CostCenter = "engineering"
}

database_config = {
  instance_class    = "db.t3.medium"
  allocated_storage = 100
  multi_az          = true
  engine_version    = "15.4"
}
```

```json
// terraform.tfvars.json (JSON format — auto-loaded)
// Useful when values are generated programmatically
{
  "environment": "prod",
  "app_name": "payment-api",
  "instance_type": "t3.large",
  "replica_count": 3,
  "enable_backups": true,
  "availability_zones": ["us-east-1a", "us-east-1b", "us-east-1c"],
  "tags": {
    "Team": "platform",
    "CostCenter": "engineering"
  }
}
```

---

### Auto-Loading vs Explicit Loading ⚠️

```
Auto-loaded (no flag needed):
  terraform.tfvars
  terraform.tfvars.json
  *.auto.tfvars           (alphabetical order)
  *.auto.tfvars.json      (alphabetical order)

Explicit (must use -var-file flag):
  prod.tfvars
  dev.tfvars
  secrets.tfvars
  any other filename
```

```bash
# Explicit loading
terraform plan -var-file="environments/prod.tfvars"

# Multiple -var-file flags — later files override earlier on same key
terraform plan \
  -var-file="base.tfvars" \
  -var-file="prod.tfvars"      # prod.tfvars values win on conflicts
```

---

### Production Multi-Environment Pattern

```
infra/
├── main.tf
├── variables.tf
├── outputs.tf
├── providers.tf
├── environments/
│   ├── dev.tfvars
│   ├── staging.tfvars
│   └── prod.tfvars
└── secrets/
    └── .gitignore      ← secrets.tfvars lives here but is gitignored
```

```hcl
# environments/dev.tfvars
environment       = "dev"
instance_type     = "t3.micro"
replica_count     = 1
enable_monitoring = false
vpc_cidr          = "10.1.0.0/16"
```

```hcl
# environments/prod.tfvars
environment       = "prod"
instance_type     = "t3.large"
replica_count     = 3
enable_monitoring = true
vpc_cidr          = "10.0.0.0/16"
```

```bash
# CI/CD pipeline commands:

# Deploy to dev
terraform plan  -var-file="environments/dev.tfvars"  -out=tfplan
terraform apply tfplan

# Deploy to prod
terraform plan  -var-file="environments/prod.tfvars" -out=tfplan
terraform apply tfplan
```

---

### What Should NOT Be in `.tfvars` — Secrets Management ⚠️

```hcl
# ❌ NEVER do this — passwords in version control
# prod.tfvars
db_password = "myS3cretP@ss"
api_key     = "sk-prod-abc123"
```

```bash
# ✅ Pattern 1: Environment variables — never in files
export TF_VAR_db_password=$(aws secretsmanager get-secret-value \
  --secret-id prod/db-password \
  --query SecretString \
  --output text)
terraform apply -var-file="prod.tfvars"
# db_password comes from TF_VAR_, other values from prod.tfvars

# ✅ Pattern 2: Use data sources instead of variables for secrets
# (See Section 2.7 — aws_secretsmanager_secret_version)

# ✅ Pattern 3: -var flag injected from CI secret store
terraform apply \
  -var-file="prod.tfvars" \
  -var="db_password=$DB_PASSWORD"  # $DB_PASSWORD from CI secret env var
```

---

### `.gitignore` for Terraform Projects

```gitignore
# .gitignore — standard Terraform project

# Local state — never commit
*.tfstate
*.tfstate.backup
*.tfstate.*.backup

# Provider binaries and plugins — regenerated by init
.terraform/

# Override files — local developer overrides
override.tf
override.tf.json
*_override.tf
*_override.tf.json

# ⚠️ Do NOT ignore this — commit it:
# .terraform.lock.hcl

# Variable files that may contain secrets
*.tfvars
# Explicitly un-ignore environment-specific non-secret tfvars:
# !environments/dev.tfvars
# !environments/staging.tfvars
# !environments/prod.tfvars

# Crash and debug logs
crash.log
crash.*.log

# Plan binary files — environment-specific, do not commit
*.tfplan
tfplan
```

---

### 🎤 Short Crisp Interview Answer

> "`.tfvars` files supply values to declared variables. `terraform.tfvars` and
> `*.auto.tfvars` are loaded automatically; any other filename needs an explicit
> `-var-file` flag. The standard production pattern is one `.tfvars` file per
> environment — dev, staging, prod — passed in during CI/CD. Secrets should
> never be in `.tfvars` files checked into version control; instead use
> `TF_VAR_` environment variables injected from a CI secret store, or data
> sources that read from Secrets Manager at plan time."

---

### ⚠️ Gotchas

- **`*.auto.tfvars` files are loaded alphabetically** — if you have both
  `10-base.auto.tfvars` and `20-overrides.auto.tfvars`, the override file wins
  for conflicting keys because it loads last. Naming matters. ⚠️
- **`terraform.tfvars` is auto-loaded even in unexpected contexts** — if a
  developer has a `terraform.tfvars` in the same directory as a module being
  tested, it will load silently and potentially break the test.
- Passing `-var-file` **does not disable auto-loading** — `terraform.tfvars`
  still loads automatically alongside your explicit file. This causes subtle
  double-assignment bugs if the same variable appears in both.
- **Type mismatches in `.tfvars` fail at plan time** — if `variables.tf`
  declares `type = list(string)` but `.tfvars` passes a string, Terraform
  errors with a type constraint violation. ⚠️

---

## 🔗 How Section 2 Connects to the Rest of the Roadmap

```
2.1 Basic syntax      ──▶  foundation for every other section
2.2 terraform block   ──▶  provider versioning (Section 3), backends (Section 10)
2.3 resource block    ──▶  meta-arguments (Section 8), state management (Section 6)
2.4 variable block    ──▶  .tfvars (2.8), module inputs (Section 7)
2.5 output block      ──▶  module composition (Section 7), remote state (Section 10)
2.6 locals block      ──▶  expressions and functions (Section 9)
2.7 data block        ──▶  remote state (Section 10), secrets (Section 16)
2.8 .tfvars           ──▶  multi-environment patterns (Section 14), CI/CD (Section 13)
```

---

## Common Interview Questions on Section 2

---

**Q: What is the difference between `variable`, `local`, and `output`?**

> "`variable` is an input — its value comes from outside the module via a
> tfvars file, CLI flag, or environment variable. It defines the module's
> interface. `local` is an internal named expression — computed from other
> values, not settable from outside, used for DRY logic and readability.
> `output` is an export — it exposes a value to the caller or to other
> configurations via remote state. Variable is input, local is internal,
> output is export."

---

**Q: What does `sensitive = true` actually protect?**

> "It redacts the value from plan and apply terminal output so it does not
> appear in logs or CI artifacts. What it does NOT do: it does not encrypt the
> value in the state file — it is still stored in plaintext there. It does not
> prevent access via `terraform output -raw`. It is a display-level protection,
> not a security boundary. For real secret management, you avoid putting secrets
> in variables at all and use data sources reading from Secrets Manager or SSM
> instead."

---

**Q: What is the `~>` version constraint operator?**

> "The pessimistic constraint operator. `~> 5.0` means >= 5.0 and < 6.0 — it
> allows any 5.x version. `~> 5.31.0` means >= 5.31.0 and < 5.32.0 — it only
> allows 5.31.x patch releases. The two-part form is more permissive than the
> three-part form. The typical production choice is `~> 5.0` — lock the major
> version, allow minor updates, and rely on the lock file for the exact pin."

---

**Q: What is the difference between a data source and a resource?**

> "A resource creates, manages, and is responsible for the lifecycle of an
> infrastructure object — Terraform owns it. A data source only reads an
> existing object — Terraform has no ownership over it and will never modify or
> destroy it. Resources have a full lifecycle in state. Data sources are also
> cached in state but are refreshed on every plan and are never destroyed by
> Terraform."

---

**Q: Which `.tfvars` files are auto-loaded and which require a flag?**

> "Terraform auto-loads `terraform.tfvars`, `terraform.tfvars.json`, and any
> file ending in `.auto.tfvars` or `.auto.tfvars.json` in alphabetical order.
> Any other filename — like `prod.tfvars` or `secrets.tfvars` — must be
> explicitly passed with the `-var-file=` flag. This distinction matters in
> CI/CD because you want explicit control over which environment file is loaded,
> not accidental auto-loading."

---

**Q: Can you have multiple `locals` blocks in one file?**

> "Yes. You can have multiple `locals` blocks across multiple files in the same
> module. They all merge into a single namespace. The only rules are: no
> duplicate names across all `locals` blocks in the same module, and references
> cannot be circular."

---

**Q: What happens if a data source references something that does not exist yet?**

> "The plan fails. Data sources that have no dependency on resources being
> created in the same apply are read during plan — if the target does not exist,
> Terraform throws an error and the plan cannot complete. This is a common issue
> in bootstrapping scenarios where you are trying to read a resource that has
> not been created yet. The solution is to either separate the creation into a
> prior apply step, or use a `depends_on` to defer the data source read to apply
> time."

---

**Q: What is the `lifecycle` block and what are its arguments?**

> "The `lifecycle` block controls how Terraform manages the lifecycle of a
> resource beyond the default create-update-destroy behavior. It has four main
> arguments: `create_before_destroy` creates the new resource before destroying
> the old one — useful for zero-downtime replacements behind a load balancer;
> `prevent_destroy` blocks any plan that would destroy the resource — useful for
> production databases; `ignore_changes` tells Terraform to ignore drift on
> specific attributes — useful when external systems like auto-scaling also
> modify the resource; and `replace_triggered_by` forces replacement of this
> resource when a referenced attribute on another resource changes."

---

*End of Section 2 — HCL: HashiCorp Configuration Language*
