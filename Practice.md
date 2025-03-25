You need to create a Terraform configuration that dynamically provisions multiple IAM users with different policies based on a list of users.
- Use a dynamic block to create IAM users from a given list.
- Assign different IAM policies based on user roles (e.g., Admin gets full access, Developer gets read-only access).
- Implement a conditional statement to create an IAM group only if the user count is greater than 5.
Provide the Terraform code that implements these dynamic and conditional configurations.
