**QUESTION --> Imagine you're working with Terraform, and you have the Terraform state file stored in an AWS S3 bucket. What would happen if you accidentally delete the state file from S3? And then, after that, if you run `terraform apply`, what would be the result?**
- Terraform would lose track of the current infrastructure it’s managing because the state file is essential for Terraform to know what resources are already created, modified, or destroyed.
- If you run `terraform apply` after deleting the state file, Terraform essentially wouldn’t be aware of the existing resources. It would treat the infrastructure as if nothing has been provisioned before. In other words, Terraform will attempt to recreate all the resources from scratch.
- Risks Involved:
  - Terraform tries to create resources that already exist, it may cause duplicates or conflict with existing resources.
  -  If the resources in the cloud have been manually modified or updated, Terraform might try to overwrite those changes
- **What would you recommend as best practices to avoid this scenario in a production environment?**
  - To avoid this scenario, I would recommend **enabling versioning on the S3 bucket** where the state file is stored. This way, if the state file is accidentally deleted, you can restore it from a previous version. 

---

You manually created an S3 bucket (e.g., my-bucket). You wrote a Terraform resource for the same bucket name. You have not imported the bucket into Terraform state. And run `terraform plan`
What will happen

- Terraform looks at its state file. The bucket is not in state, so Terraform thinks it doesn’t exist.
- Terraform compares code vs. state: The resource is in code, not in state → Terraform plans to create it.
- Terraform does not check AWS yet for conflicts at `plan` time.
- Terraform plan will succeed. It will show that it wants to create the S3 bucket, like this:
```hcl
# aws_s3_bucket.my_bucket will be created
  + resource "aws_s3_bucket" "my_bucket" {
      + bucket = "my-bucket"
      + acl    = "private"
      ...
    }
```
