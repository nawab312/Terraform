- Set up a **Remote State Backend** using **Amazon S3** and **DynamoDB** for state locking. 

### Steps for Setting Up Remote State Backend

**Create the S3 Bucket**
- Go to the **S3 Console** in AWS.
- Create a new bucket, e.g., `sid-312-terraform-bucket-s3`.
   - Enable **Versioning** for the bucket.
   - Enable **Server-Side Encryption** (e.g., SSE-S3 or SSE-KMS).
- Ensure that **Block all public access** is turned on to prevent unauthorized access to the state file.

**Create the DynamoDB Table**
- Go to the **DynamoDB Console** in AWS.
- Create a new table with:
   - **Table name**: `my-terraform-lock-table`
   - **Primary Key**: `LockID` (String).

**Configure Terraform to Use the Remote Backend**

```hcl
# backend.tf - Backend configuration for Terraform

terraform {
  backend "s3" {
    bucket = "sid-312-terraform-bucket-s3"
    key = "terraform.tfstate"
    region = "us-east-1"
    encrypt = true
    dynamodb_table = "my-terraform-lock-table"
  }
}
```

```hcl
# main.tf

terraform {
  required_providers {
    aws = {
        version = "5.88.0"
        source = "hashicorp/aws"
    }
  }
}
```

```bash
terraform init

Initializing the backend...

Successfully configured the backend "s3"! Terraform will automatically
use this backend unless the backend configuration changes.
```

```bash
terraform apply
```

![image](https://github.com/user-attachments/assets/9630881d-64a9-4e0f-ad3d-4c09e1eb6ce2)

- **Testing Concurrent Access** Run a terraform apply command in one terminal. While it’s running, open a second terminal and try to apply changes again. The second terminal should show a lock error, confirming that the state is locked.

```bash
terraform apply
Acquiring state lock. This may take a few moments...
╷
│ Error: Error acquiring the state lock
│ 
│ Error message: ConditionalCheckFailedException: The conditional request failed
│ Lock Info:
│   ID:        bcf451e9-1e67-a2a4-4b6c-49e29e784cb0
│   Path:      sid-312-terraform-bucket-s3/terraform.tfstate
│   Operation: OperationTypeApply
│   Who:       siddharth312@siddharth312-GF65-Thin-9SD
│   Version:   1.5.0
│   Created:   2025-02-26 13:52:01.054945615 +0000 UTC
│   Info:      
│ 
│ 
│ Terraform acquires a state lock to protect the state from being written
│ by multiple users at the same time. Please resolve the issue above and try
│ again. For most commands, you can disable locking with the "-lock=false"
│ flag, but this is not recommended.
```

- Terraform automatically unlocks the state after a successful run, but if a process is interrupted, you might need to unlock it manually: `terraform force-unlock <LOCK_ID>`
- This command will move the state file from its current location to the specified backend (Like local to S3): `terraform init -migrate-state`

