# Infrastructure — Terraform Monorepo

> AWS infrastructure as code. Industry-standard structure.
> Deploy → practice → destroy. Repeat.

---

## Repository structure

```
terraform-infra/
├── modules/
│   ├── vpc/                    # Reusable VPC module
│   │   ├── main.tf
│   │   ├── variables.tf
│   │   ├── outputs.tf
│   │   └── versions.tf
│   └── eks/                    # Reusable EKS module
│       ├── main.tf
│       ├── variables.tf
│       ├── outputs.tf
│       └── versions.tf
│
├── environments/
│   └── dev/                    # Dev/lab environment
│       ├── main.tf             # Calls modules, wires everything together
│       ├── variables.tf        # Environment-level variables
│       ├── outputs.tf          # Outputs (cluster endpoint, kubeconfig cmd)
│       ├── terraform.tfvars    # Actual values (gitignored for secrets)
│       ├── backend.tf          # S3 remote state config
│       └── versions.tf         # Provider + terraform version pins
│
├── scripts/
│   ├── bootstrap.sh            # One-time: create S3 bucket + DynamoDB table
│   └── destroy.sh              # Safe teardown with confirmation
│
├── .github/
│   └── workflows/
│       └── terraform.yml       # CI: fmt, validate, tflint, tfsec on PR
│
├── .tflint.hcl                 # tflint config
├── .trivyignore                # Trivy false positive suppressions
├── .gitignore
└── README.md
```

---

## Prerequisites

```bash
# Install required tools
brew install terraform          # or tfenv for version management
brew install awscli
brew install kubectl
brew install tflint
brew install tfsec              # or: brew install aquasecurity/trivy/trivy
brew install pre-commit

# AWS credentials configured
aws configure
# or set environment variables:
export AWS_PROFILE=my-profile
export AWS_REGION=ap-south-1
```

---

## First-time bootstrap (run ONCE)

```bash
# Creates: S3 bucket for state + DynamoDB table for locking
chmod +x scripts/bootstrap.sh
./scripts/bootstrap.sh

# You'll be prompted for:
#   - AWS region
#   - Project name (used as prefix for bucket name)
```

---

## Deploy

```bash
cd environments/dev

# 1. Initialize — downloads providers, configures backend
terraform init

# 2. Review what will be created
terraform plan

# 3. Deploy
terraform apply

# 4. Get kubeconfig after deploy
aws eks update-kubeconfig \
  --region $(terraform output -raw region) \
  --name $(terraform output -raw cluster_name)

# 5. Verify
kubectl get nodes
```

---

## Destroy (when done practicing)

```bash
# Safe destroy with confirmation prompt
chmod +x scripts/destroy.sh
./scripts/destroy.sh dev

# Or directly:
cd environments/dev
terraform destroy
```

---

## Adding more components (future)

When ready to add RDS, ElastiCache, ALB:

```
1. Create modules/rds/
2. Add to environments/dev/main.tf
3. Run terraform plan → terraform apply
```

---

## Cost estimate (dev environment)

| Resource | Type | Est. cost/day |
|----------|------|---------------|
| EKS control plane | Managed | $0.10 |
| EC2 nodes | t3.medium × 2 | ~$0.19 |
| NAT Gateway | 2 × AZ | ~$0.09 |
| EBS volumes | 20GB × 2 | ~$0.05 |
| **Total** | | **~$0.43/day** |

> **Destroy when not in use.** A full day costs ~$0.43. Leave it running a month = ~$13.

---

## Rules

1. **Never hardcode values** — everything is a variable
2. **Never commit secrets** — use AWS Secrets Manager or environment variables
3. **Always run `terraform plan` before `apply`**
4. **Always destroy when done** — don't leave resources running
5. **Never edit state manually** — let Terraform manage it
6. **Lock provider versions** — reproducible builds
