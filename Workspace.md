- A workspace in Terraform is a way to maintain **multiple state files** for the same Terraform configuration.
- By default, Terraform uses the `default` workspace.
```bash
terraform workspace new dev
terraform workspace new prod
```

<img width="578" height="171" alt="image" src="https://github.com/user-attachments/assets/559e93ca-61cd-4049-b995-eb46f4dfa6dd" />

**What Problem Does It Solve?**
- Imagine: Same VPC code, Same VPC code, Same RDS code
- But you want: Dev environment, Staging, Prod

**How It Works Internally**
- Terraform determines: `terraform.workspace`
- You can use this in code: `instance_type = terraform.workspace == "prod" ? "t3.large" : "t3.micro"`

**How to Use It**
- Check current workspace: `terraform workspace show`
- Switch workspace: `terraform workspace select dev`
- List workspace: `terraform workspace list`

---

**If dev and prod are in different AWS accounts, is workspace still a good design? Why or why not?**
- NO ITS NOT A GOD DESIGN
- Workspaces Only Isolate State
- They do NOT isolate: AWS credentials, IAM Roles, Backend Config, Providers
- Imagine:
  ```bash
  terraform workspace select prod
  terraform apply
  ```
- But your AWS credentials are still pointing to Dev account.
- Better Patterb:
  ```bash
  envs/
  dev/
    main.tf
    backend.tf
    providers.tf
  prod/
    main.tf
    backend.tf
    providers.tf
  modules/
    vpc/
    ec2/
    rds/
  ```
  

