# Terraform Interview Mastery — Section 1: Core Concepts & Architecture

---

## Table of Contents

- [1.1 What is Terraform & How It Fits in the IaC Landscape](#11-what-is-terraform--how-it-fits-in-the-iac-landscape)
- [1.2 Declarative vs Imperative IaC](#12-declarative-vs-imperative-iac)
- [1.3 The Terraform Workflow: init → plan → apply → destroy](#13-the-terraform-workflow-init--plan--apply--destroy)
- [1.4 How Terraform Talks to Cloud Providers](#14-how-terraform-talks-to-cloud-providers-api-based-provisioning)
- [1.5 Terraform vs Terraform Cloud vs Terraform Enterprise](#15-terraform-vs-terraform-cloud-vs-terraform-enterprise)
- [How Section 1 Connects to the Rest of the Roadmap](#-how-section-1-connects-to-the-rest-of-the-roadmap)
- [Common Interview Questions on Section 1](#common-interview-questions-on-section-1)

---

## 1.1 What is Terraform & How It Fits in the IaC Landscape

### What it is (simple terms)

Terraform is an open-source tool by HashiCorp that lets you define your entire
infrastructure — servers, databases, networks, DNS records, IAM roles — as code,
and then create/manage/destroy that infrastructure through a CLI. Instead of
clicking around in a cloud console, you write `.tf` files and Terraform figures
out the API calls needed to make reality match your code.

### Why it exists — the problem it solves

Before IaC, infra was managed by:

- Clicking through cloud consoles (no audit trail, not repeatable)
- Shell scripts calling CLIs (fragile, order-dependent, no idempotency)
- "Snowflake servers" — unique configurations no one fully understood

Terraform solves:

- **Repeatability** — same code → same infra, every time
- **Drift prevention** — desired state is codified and auditable
- **Multi-cloud** — one tool, one workflow, any cloud
- **Collaboration** — infra lives in Git, reviewed like application code

---

### The IaC Landscape — Where Terraform Sits

| Tool              | Type          | Approach                    | Language          | Scope            | State        |
|-------------------|---------------|-----------------------------|-------------------|------------------|--------------|
| **Terraform**     | Provisioning  | Declarative                 | HCL               | Multi-cloud infra| Yes (tfstate)|
| **Ansible**       | Config Mgmt   | Imperative/Declarative hybrid | YAML            | OS config, app deploy | No (agentless) |
| **Pulumi**        | Provisioning  | Declarative (imperative DSL)| Python/TS/Go/C#   | Multi-cloud infra| Yes          |
| **CloudFormation**| Provisioning  | Declarative                 | JSON/YAML         | AWS only         | Yes (CF stacks)|
| **CDK**           | Provisioning  | Imperative DSL → CF         | Python/TS/Java    | AWS only         | Via CF       |

---

### Deep-Dive Comparisons

#### Terraform vs Ansible

```
Terraform  → "What should exist" (infrastructure provisioning)
Ansible    → "What should be configured" (software/OS configuration)
```

These are **complementary, not competing**. The canonical production pattern:

- Terraform provisions the EC2 instance, VPC, security groups, IAM roles
- Ansible configures the OS, installs packages, deploys app config

Terraform is not designed to run commands inside a running OS.
Ansible is not designed to create/destroy cloud resources from scratch
(though it can, it's painful).

---

#### Terraform vs CloudFormation

```hcl
# Terraform — same code, works on AWS, GCP, Azure, Datadog, GitHub...
resource "aws_instance" "web" {
  ami           = "ami-0c55b159cbfafe1f0"
  instance_type = "t3.micro"
}
```

```yaml
# CloudFormation — AWS only, JSON/YAML, verbose
Resources:
  WebInstance:
    Type: AWS::EC2::Instance
    Properties:
      ImageId: ami-0c55b159cbfafe1f0
      InstanceType: t3.micro
```

**Key differences:**

- CloudFormation is **AWS-native** — better AWS service coverage on day-zero,
  no state file to manage (AWS manages it)
- Terraform is **multi-cloud** — one mental model across AWS, GCP, Azure,
  Cloudflare, PagerDuty, etc.
- CloudFormation **rollbacks** are automatic on failure; Terraform does not
  auto-rollback ⚠️
- Terraform **plan** gives you a human-readable diff before applying;
  CloudFormation change sets are less intuitive
- CloudFormation has no concept of drift detection UI as clean as
  `terraform plan`

---

#### Terraform vs Pulumi

```
Terraform  → HCL (domain-specific, purpose-built, easier for ops teams)
Pulumi     → Real programming languages (better for dev-heavy teams,
             loops/conditionals feel natural)
```

Both use a state-based model.

- Pulumi's advantage: when logic is genuinely complex — conditional resource
  creation, complex loops, unit testing with real test frameworks
- Terraform's advantage: ecosystem maturity, the Registry, and HCL's
  readability for non-developers

---

### 🎤 Short Crisp Interview Answer

> "Terraform is a declarative, cloud-agnostic infrastructure provisioning tool.
> You define desired state in HCL, and Terraform computes what API calls are
> needed to reach that state, manages a state file to track what it created,
> and can plan changes before applying them. It sits in the provisioning layer
> of IaC — you'd use it alongside Ansible for config management, not instead
> of it. Compared to CloudFormation, it's multi-cloud and has a better
> plan/diff experience. Compared to Pulumi, it uses HCL instead of
> general-purpose languages, which is simpler but less flexible for complex
> logic."

---

### 🔬 Deeper Answer

> "Terraform's core differentiator is its provider plugin architecture. Any API
> with a REST or gRPC interface can become a Terraform provider — AWS, GCP,
> Azure, GitHub, Datadog, PagerDuty, even internal company APIs. This means your
> entire platform — cloud infra, monitoring, DNS, on-call schedules — can be
> managed as a unified codebase. CloudFormation can't touch your Datadog
> monitors. Ansible can, but it won't maintain a state model. That unified state
> model is what gives Terraform its drift detection and safe-change-planning
> superpowers."

---

### ⚠️ Common Gotchas / Tricky Interview Points

- Candidates say "Terraform replaces Ansible" — **wrong**. Different layers,
  complementary tools.
- "CloudFormation manages state too, so why use Terraform?" — CloudFormation
  state is opaque and AWS-managed. You can't inspect it, move it, or surgically
  manipulate it the way you can `terraform.tfstate`.
- Pulumi doesn't mean "write imperative code" — it still compiles down to a
  graph of desired state. The *definition* is written imperatively but the
  *execution model* is still declarative.

---

## 1.2 Declarative vs Imperative IaC

### What it is (simple terms)

- **Declarative**: You describe *what* you want. The tool figures out *how* to
  get there.
- **Imperative**: You describe *how* to do it, step by step.

### Why this distinction matters

**Imperative script (Bash/Python):**

```bash
# You must handle every case yourself
if ! aws ec2 describe-instances --filters "Name=tag:Name,Values=web" | grep running; then
  aws ec2 run-instances --image-id ami-abc123 --instance-type t3.micro
  # But what if it partially exists? What if we need 3 now instead of 2?
  # The script breaks. You write more conditionals. It becomes unmaintainable.
fi
```

**Declarative Terraform:**

```hcl
# You say WHAT you want. Terraform figures out the diff.
resource "aws_instance" "web" {
  count         = 3           # Change this to 5? Terraform adds exactly 2 more.
  ami           = "ami-abc123"
  instance_type = "t3.micro"
}
```

---

### How Declarative IaC Works Internally

Terraform's engine does this on every `plan`:

```
1. Read desired state   → from your .tf files
2. Read actual state    → from terraform.tfstate
                          (and optionally refresh from real API)
3. Compute diff         → what needs to be created / updated / destroyed
4. Build action plan    → ordered by dependency graph
5. On apply             → execute only the necessary API calls
```

This is called **convergence** — Terraform converges actual state toward desired
state. You can run `apply` 10 times on the same code with no changes and nothing
will happen. That's **idempotency** — a critical property.

---

### ⚠️ The Three-Way Relationship

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   .tf files     │     │ terraform.tfstate │     │   Real Cloud    │
│  (desired)      │ ──▶ │  (known state)    │ ──▶ │   (actual)      │
└─────────────────┘     └──────────────────┘     └─────────────────┘
         │                                                │
         └──────────────── plan computes diff ────────────┘
```

When these three diverge, you get **drift** — one of the most important
operational problems in Terraform.

---

### 🎤 Short Crisp Interview Answer

> "Declarative IaC means you define the desired end state, and the tool computes
> what changes are needed to reach it — you don't script the steps. Terraform is
> declarative: I say 'I want 3 EC2 instances', and whether there are currently
> 0, 2, or 5, Terraform figures out the exact API calls to get to 3. This gives
> you idempotency — applying the same config repeatedly converges to the same
> state without unintended side effects."

---

### 🔬 Deeper Answer

> "The declarative model only works cleanly because Terraform maintains a state
> file. Without it, Terraform would have to fully query the API on every run to
> understand current state — which is slow and sometimes impossible since not all
> attributes are readable back from APIs. The state file is the 'known good
> last-applied' snapshot. The plan diff is between desired state in `.tf` files
> and known state in the state file, with an optional real-API refresh step.
> This is why imperative mutations — like manually changing something in the
> console — break Terraform's model and cause drift."

---

### ⚠️ Gotchas

- Terraform is declarative, but it has **procedural escape hatches** —
  `null_resource`, `local-exec`, `remote-exec`. These are imperative and break
  idempotency if not carefully written.
- "Declarative = no ordering needed" — **false**. Terraform still has an
  internal execution order dictated by the dependency graph. Declarative means
  *you* don't specify the order, not that order doesn't exist.

---

## 1.3 The Terraform Workflow: `init → plan → apply → destroy`

### What it is

The four core CLI commands that form every Terraform operation.

---

### `terraform init`

**What it does:**

```
1. Reads terraform {} block and required_providers
2. Downloads provider plugins from registry.terraform.io (or custom URL)
3. Downloads modules referenced in module {} blocks
4. Initializes the backend (local or remote)
5. Creates .terraform/ directory and .terraform.lock.hcl
```

**Common usage:**

```bash
# Standard initialization
terraform init

# With backend config override (common in CI)
terraform init \
  -backend-config="bucket=my-tf-state" \
  -backend-config="key=prod/terraform.tfstate"

# Upgrade providers to latest allowed by version constraints
terraform init -upgrade

# Migrate state to new backend
terraform init -migrate-state
```

---

#### ⚠️ The `.terraform.lock.hcl` File

```hcl
# This is your provider version lock file — COMMIT THIS TO GIT
provider "registry.terraform.io/hashicorp/aws" {
  version     = "5.31.0"
  constraints = "~> 5.0"
  hashes = [
    "h1:abcdef...",  # Platform-specific checksums for integrity verification
    "zh:123456...",  # zh = zip hash — content hash of the .zip provider binary
  ]
}
```

This ensures every team member and CI pipeline uses the **exact same provider
version and binary**. Not committing it means different engineers may use
different provider versions → inconsistent behavior.

---

### `terraform plan`

**What it does internally:**

```
1. Loads and validates all .tf files
2. Reads current state from backend (local or remote)
3. Runs a "refresh" against real APIs (unless -refresh=false)
4. Builds the dependency graph (DAG)
5. For each resource: computes create/update/delete/no-op
6. Outputs the diff — never touches real infrastructure
```

**Common usage:**

```bash
# Standard plan
terraform plan

# Save plan to file — critical for CI/CD (apply exactly what was reviewed)
terraform plan -out=tfplan.binary

# Skip the API refresh step (faster, but may miss real drift)
terraform plan -refresh=false

# Only plan specific resources (use with caution) ⚠️
terraform plan -target=aws_instance.web

# Pass variable inline
terraform plan -var="environment=prod"
```

---

#### Reading Plan Output

```
Terraform will perform the following actions:

  # aws_instance.web will be created                 ← + green
  + resource "aws_instance" "web" {
      + ami           = "ami-0c55b159cbfafe1f0"
      + instance_type = "t3.micro"
    }

  # aws_security_group.web will be updated in-place  ← ~ yellow
  ~ resource "aws_security_group" "web" {
      ~ description = "old" -> "new"
    }

  # aws_instance.old must be replaced                ← -/+ red — DANGEROUS ⚠️
  -/+ resource "aws_instance" "old" {
      ~ ami = "ami-old" -> "ami-new" # forces replacement
    }

Plan: 1 to add, 1 to change, 1 to destroy.
```

> ⚠️ The `-/+` symbol means **destroy and recreate** — a forced replacement.
> This is one of the most important things to catch in plan review because it
> may cause downtime.

---

### `terraform apply`

**What it does:**

```
1. Runs a plan (unless -auto-approve with saved plan file)
2. Prompts for confirmation (yes/no)
3. Walks the dependency graph, executing API calls in parallel
4. Updates state file after each resource success
5. Reports errors without rolling back completed resources ⚠️
```

**Common usage:**

```bash
# Default (runs plan inline, prompts for confirmation)
terraform apply

# Apply a saved plan — this is the CORRECT CI/CD pattern
terraform apply tfplan.binary

# Skip confirmation — only safe with saved plan + reviewed output
terraform apply -auto-approve

# Limit parallel operations (useful for APIs with rate limits)
terraform apply -parallelism=5
```

---

#### ⚠️ Critical: No Automatic Rollback

If `apply` starts, creates 10 resources, then fails on resource 11 — the first
10 remain created. Terraform does **not** roll back. This is a fundamental
difference from CloudFormation. The state file will reflect whatever was
successfully created. Your recovery path is to fix the error and re-apply, or
surgically destroy specific resources.

---

### `terraform destroy`

```bash
# Destroy all resources in state
terraform destroy

# Generate a destroy plan first (safe approach)
terraform plan -destroy -out=destroy.tfplan
terraform apply destroy.tfplan

# Destroy specific resource
terraform destroy -target=aws_instance.web
```

**What it does:** Reads state, builds a destruction plan (reverse dependency
order — dependents before dependencies), confirms, then destroys.

---

### Full CI/CD Workflow Pattern (Production)

```
┌──────────┐    ┌──────────┐    ┌──────────┐    ┌──────────┐
│  PR Open │───▶│   init   │───▶│   plan   │───▶│  Review  │
└──────────┘    └──────────┘    └──────────┘    └──────────┘
                                      │                │
                              save tfplan.binary   human/bot
                                                   approval
                                                       │
┌──────────┐    ┌──────────┐    ┌──────────┐           │
│ PR Merge │───▶│   init   │───▶│  apply   │◀──────────┘
└──────────┘    └──────────┘    │(tfplan)  │
                                └──────────┘
```

> The key discipline: **plan in PR, apply on merge using saved plan artifact**.
> Never re-plan at apply time in CI, because state could change between the
> plan review and apply execution.

---

### 🎤 Short Crisp Interview Answer

> "`init` downloads providers and sets up the backend. `plan` is a dry run — it
> reads current state, queries the real API, computes a diff, and shows you
> exactly what will change without touching anything. `apply` executes that plan
> and updates the state file. `destroy` is essentially a plan and apply but with
> all resources marked for deletion. In CI/CD, the correct pattern is to save
> the plan as a binary artifact, get it reviewed, then apply that exact artifact
> — never re-plan at apply time."

---

### ⚠️ Gotchas

- **`apply` doesn't auto-rollback** — partial failures leave partial state.
  CloudFormation does rollback; Terraform doesn't.
- Running `apply` without a saved plan file means Terraform re-runs the plan
  internally — if state changed between your review and apply, you apply
  different changes than what you reviewed. ⚠️
- `init` must be re-run any time you add a new provider or change the backend
  config.
- `.terraform/` directory should be in `.gitignore`.
  `.terraform.lock.hcl` should **NOT** be.

---

## 1.4 How Terraform Talks to Cloud Providers (API-based Provisioning)

### What it is

Terraform doesn't have built-in knowledge of AWS, GCP, or Azure. It relies on
**provider plugins** — separate Go binaries that translate HCL resource
definitions into cloud API calls.

---

### The Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                    terraform (core binary)                      │
│                                                                │
│  .tf files → HCL parser → graph builder → plan engine         │
│                                    │                           │
│                            RPC calls (gRPC)                    │
└────────────────────────────────────┼───────────────────────────┘
                                     │
           ┌──────────────────────── ┼ ──────────────────────────┐
           │                         │                           │
    ┌──────┴──────┐         ┌────────┴─────┐         ┌──────────┴────┐
    │ aws provider│         │ gcp provider │         │ azure provider│
    │  (plugin)   │         │  (plugin)    │         │  (plugin)     │
    └──────┬──────┘         └──────┬───────┘         └──────┬────────┘
           │                       │                         │
    AWS REST APIs            GCP REST APIs             Azure REST APIs
```

---

### How it Works Internally

**Step 1 — `terraform init`**
Downloads the provider binary
(e.g., `terraform-provider-aws_v5.31.0_linux_amd64.zip`) from the Terraform
Registry and stores it in `.terraform/providers/`

**Step 2 — Provider starts as a subprocess**
When you run `plan` or `apply`, Terraform core launches the provider binary as
a subprocess and communicates with it via **gRPC** over a local socket.

**Step 3 — Schema exchange**
The provider tells Terraform core what resources and data sources it supports,
and what attributes each accepts (types, required/optional, computed, ForceNew).

**Step 4 — CRUD operations**
For each resource, the provider implements 4 functions:

- `Create` → POST/PUT to cloud API
- `Read`   → GET from cloud API (used in refresh)
- `Update` → PATCH/PUT to cloud API
- `Delete` → DELETE to cloud API

**Example — what happens under the hood:**

```hcl
# When you write this...
resource "aws_s3_bucket" "data" {
  bucket = "my-company-data-bucket"
  tags = {
    Environment = "prod"
  }
}

# Terraform core calls the AWS provider's Create function.
# The provider translates this to:
#   POST https://s3.amazonaws.com/
#   CreateBucket(BucketName="my-company-data-bucket", ...)
#   Then calls PutBucketTagging(...)
```

**Step 5 — Authentication**
The provider handles auth, not Terraform core. The AWS provider reads
credentials from env vars, `~/.aws/credentials`, instance profiles, or OIDC
tokens.

```hcl
provider "aws" {
  region = "us-east-1"
  # In CI/CD: credentials come from environment variables
  # AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
  # Or preferably: OIDC role assumption (no long-lived keys)

  # Assume a specific role (least privilege pattern)
  assume_role {
    role_arn = "arn:aws:iam::123456789012:role/TerraformExecutionRole"
  }
}
```

---

### ⚠️ ForceNew — The Most Important Provider Schema Concept

```hcl
resource "aws_instance" "web" {
  ami           = "ami-new"   # ForceNew=true in provider schema
  instance_type = "t3.micro"
}
```

When a provider marks an attribute as `ForceNew=true`, changing that attribute
**cannot be done in-place** — it requires destroy + recreate. The AMI ID on an
EC2 instance is ForceNew. The bucket name on S3 is ForceNew. You'll see `-/+`
in the plan output. This is critical to catch before applying.

---

### 🎤 Short Crisp Interview Answer

> "Terraform core is actually agnostic to any specific cloud. It delegates all
> cloud-specific operations to provider plugins — separate Go binaries that
> Terraform communicates with via gRPC. The provider translates HCL resource
> definitions into the actual REST API calls for that cloud. When you run init,
> Terraform downloads the provider binary. At plan and apply time, the
> provider's Read function is called to refresh state, and Create/Update/Delete
> functions are called to make changes. Authentication is handled entirely by
> the provider, not by Terraform core."

---

### 🔬 Deeper Answer

> "The provider plugin protocol is versioned and uses protocol buffers over
> gRPC. Provider authors implement a Go SDK that handles all the boilerplate —
> resource schema definition, CRUD wiring, error handling. When Terraform runs
> a plan, it calls the provider's Read (or Refresh) functions for every resource
> in state to get the current real-world values, then diffs those against your
> `.tf` files. The schema also encodes which attribute changes require
> ForceNew — a destroy and recreate — which is why you see `-/+` in the plan.
> This ForceNew metadata lives entirely in the provider, not in Terraform core,
> which is why updating a provider version can suddenly change whether a
> resource will be replaced."

---

### ⚠️ Gotchas

- The provider version determines what resources and attributes are available.
  An older AWS provider won't know about resources released after its version.
  Always check the provider changelog when a new AWS service isn't showing up.
- API rate limiting is handled by the provider — if you hit AWS rate limits,
  the provider has built-in retry logic, but with 100s of resources it can still
  fail. Use `-parallelism` to tune.
- Some attributes are **write-only** (like IAM user passwords, RDS passwords)
  — the provider can't read them back from the API, so Terraform stores the
  value in state. This is a **security concern** — plaintext secrets in
  state. ⚠️

---

## 1.5 Terraform vs Terraform Cloud vs Terraform Enterprise

### What They Are

```
┌──────────────────────────────────────────────────────────────────┐
│                        Terraform (OSS)                           │
│  • Free, open source CLI                                         │
│  • You manage: state storage, CI/CD, secrets, access control    │
│  • State: local OR self-managed remote backend (S3, GCS, etc.)  │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                   Terraform Cloud (HCP Terraform)                │
│  • SaaS platform by HashiCorp (free tier + paid)                │
│  • Remote execution (runs plan/apply on HashiCorp's infra)      │
│  • State management built-in (no S3 bucket needed)              │
│  • VCS integration, team access controls, audit logs            │
│  • Sentinel policy enforcement (paid)                           │
│  • Cost estimation (paid)                                       │
└──────────────────────────────────────────────────────────────────┘

┌──────────────────────────────────────────────────────────────────┐
│                  Terraform Enterprise (TFE)                      │
│  • Self-hosted version of Terraform Cloud                        │
│  • Everything in TF Cloud + runs in YOUR VPC/datacenter         │
│  • No data leaves your network (compliance requirement driver)  │
│  • Used by banks, healthcare, defense — regulated industries    │
│  • Audit logging, SSO, SAML, custom Sentinel policies           │
└──────────────────────────────────────────────────────────────────┘
```

---

### Feature Comparison

| Feature             | OSS           | Cloud (Free)  | Cloud (Plus)  | Enterprise    |
|---------------------|---------------|---------------|---------------|---------------|
| State management    | Self-managed  | ✅ Built-in   | ✅ Built-in   | ✅ Built-in   |
| State locking       | Self-managed  | ✅            | ✅            | ✅            |
| Remote execution    | ❌            | ✅            | ✅            | ✅            |
| VCS integration     | ❌            | ✅            | ✅            | ✅            |
| Sentinel policies   | ❌            | ❌            | ✅            | ✅            |
| Audit logs          | ❌            | ❌            | ✅            | ✅            |
| SSO / SAML          | ❌            | ❌            | ✅            | ✅            |
| Self-hosted         | ✅            | ❌            | ❌            | ✅            |
| Cost estimation     | ❌            | ❌            | ✅            | ✅            |
| Private registry    | ❌            | ✅            | ✅            | ✅            |

---

### Remote Execution Model — The Key TFC Differentiator

**With Terraform OSS + S3 backend:**
`plan` and `apply` run on your machine or CI runner.
Credentials must exist where the CLI runs.

**With Terraform Cloud:**
Execution happens in HCP's infrastructure:

```
Your laptop/CI system           Terraform Cloud
┌─────────────────┐            ┌──────────────────────────────┐
│  git push       │──trigger──▶│  1. Clone repo               │
│  (VCS webhook)  │            │  2. terraform init           │
└─────────────────┘            │  3. terraform plan           │
                               │  4. Wait for approval        │
                               │  5. terraform apply          │
                               │  6. Store state              │
                               └──────────────────────────────┘
```

The cloud execution environment holds the credentials (via Variable Sets),
not your laptop. Developers never touch credentials directly.

---

### Sentinel Policy as Code (TFE / TFC Plus)

```python
# Example Sentinel policy — enforce all S3 buckets must have encryption
import "tfplan/v2" as tfplan

s3_buckets = filter tfplan.resource_changes as _, rc {
    rc.type is "aws_s3_bucket" and
    rc.mode is "managed" and
    (rc.change.actions contains "create" or rc.change.actions contains "update")
}

violation = rule {
    all s3_buckets as _, bucket {
        bucket.change.after.server_side_encryption_configuration is not null
    }
}

main = rule { violation }
```

Sentinel runs as a **gate between plan and apply**. If a policy fails, apply is
blocked. This is critical for large orgs that need guardrails — e.g.,
"no internet-facing security groups", "all resources must have cost center tags",
"no t3.xlarge in dev environment".

---

### When Would You Choose Each?

| Scenario                                              | Recommendation              |
|-------------------------------------------------------|-----------------------------|
| Small team, startup, full control needed              | OSS + S3 backend + GitHub Actions |
| Growing team, want collaboration features             | Terraform Cloud (free tier) |
| Org needs Sentinel, audit trails, SSO                 | Terraform Cloud Plus        |
| Bank, hospital, regulated industry, no SaaS allowed  | Terraform Enterprise (self-hosted) |

---

### Modern Terraform Cloud Configuration

```hcl
# Modern way to connect to Terraform Cloud
terraform {
  cloud {
    organization = "my-company"
    workspaces {
      name = "production-aws"
    }
  }
}
```

---

### 🎤 Short Crisp Interview Answer

> "Terraform OSS is the CLI tool — you bring your own state storage, CI, and
> access control. Terraform Cloud is HashiCorp's SaaS platform that adds remote
> execution, built-in state management, VCS integration, and team collaboration.
> Terraform Enterprise is the same thing but self-hosted, for organizations that
> can't let data leave their network — typically regulated industries like
> banking or healthcare. The key architectural difference is that TFC/TFE move
> plan and apply execution to HashiCorp's or your own infrastructure, so
> individual developers never touch credentials directly."

---

### ⚠️ Gotchas

- **OpenTofu** — since HashiCorp changed Terraform's license to BSL in 2023,
  the community forked it as OpenTofu (under the Linux Foundation). It is
  currently at feature parity with Terraform ~1.6 and is a drop-in replacement
  for most use cases. This is increasingly coming up in interviews.
- The `cloud {}` backend block replaced the old `remote` backend block for TFC
  configuration. Interviewers may ask which is correct.
- TFC free tier still runs remotely — this surprises people who think only paid
  plans get remote execution.

---

## 🔗 How Section 1 Connects to the Rest of the Roadmap

```
1.1 IaC landscape  ──▶  drives why state management exists (Section 6)
1.2 Declarative    ──▶  explains how plan/diff works (Section 12)
1.3 Workflow       ──▶  foundation for CI/CD patterns (Section 13)
1.4 Provider model ──▶  provider versioning & aliases (Section 3)
1.5 TFC/TFE        ──▶  remote state, Sentinel, team patterns (Section 17)
```

---

## Common Interview Questions on Section 1

---

**Q: Why would you choose Terraform over CloudFormation for an AWS-only shop?**

> "Even in an AWS-only environment, Terraform offers advantages: better plan
> output readability, a richer module ecosystem on the public registry,
> consistent tooling if you ever add a second cloud or SaaS provider, and more
> intuitive drift detection. That said, CloudFormation has better day-zero
> support for new AWS services and native rollback. The decision often comes
> down to whether you value AWS-native integration or a consistent
> multi-cloud/multi-service workflow."

---

**Q: What happens if `terraform apply` fails halfway through?**

> "There's no automatic rollback. Resources successfully created before the
> failure remain in place and are recorded in the state file. The fix is to
> identify the failure reason, fix the code or the underlying issue, and re-run
> apply. Terraform will skip already-created resources (they're in state) and
> retry from the failure point."

---

**Q: Why do we commit `.terraform.lock.hcl` but not `.terraform/`?**

> "`.terraform.lock.hcl` records the exact provider version and hash checksums
> — it ensures everyone on the team and CI uses identical provider binaries.
> `.terraform/` contains the actual downloaded provider binaries, which are
> large, platform-specific, and can be regenerated with `init`."

---

**Q: What is the difference between Terraform OSS and Terraform Cloud?**

> "Terraform OSS is the open source CLI. You are responsible for managing state
> storage (typically in S3 or GCS), CI/CD pipelines, secrets, and team access
> controls yourself. Terraform Cloud is a SaaS platform by HashiCorp that
> provides all of that out of the box — built-in state management with locking,
> remote plan and apply execution, VCS-driven workflows, team permissions, and
> (on paid tiers) Sentinel policy enforcement and audit logging. The most
> important architectural difference is that with TFC, plan and apply run in
> HashiCorp's infrastructure, so developers on your team never need direct
> access to cloud credentials."

---

**Q: What is the declarative model and why does it require state?**

> "In the declarative model you describe the desired end state, not the steps
> to get there. Terraform then computes the diff between desired state and
> current state and executes only the necessary changes. State is required
> because Terraform needs a reliable record of what it last created — it uses
> this to compute the diff rather than fully querying the cloud API on every run,
> which would be slow and incomplete since some attributes are write-only and
> cannot be read back."

---

**Q: What is `.terraform.lock.hcl` and should it be committed to version control?**

> "Yes, it should always be committed. The lock file records the exact provider
> version selected and its cryptographic hash checksums for each platform.
> Committing it ensures that every developer on the team and every CI pipeline
> run uses the exact same provider binary. Without it, running `terraform init`
> at different times could pull different patch versions of a provider, leading
> to inconsistent behavior or unexpected plan output."

---

*End of Section 1 — Core Concepts & Architecture*
