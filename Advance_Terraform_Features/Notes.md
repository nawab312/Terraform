The **terraform taint** command was used to manually mark a resource as tainted, meaning Terraform would destroy and recreate it in the next terraform apply execution. Use Case:
- If a resource was in an inconsistent or faulty state.
- If a resource needed to be replaced without modifying the configuration.
```bash
terraform taint <resource_type>.<resource_name>
```

The **terraform untaint** command was used to remove the taint from a resource, preventing Terraform from destroying and recreating it. Use Case:
- If a resource was mistakenly tainted and you no longer want it to be replaced.
```bash
terraform untaint <resource_type>.<resource_name>
```

*Since Terraform 1.0, `terraform taint` and `terraform untaint` are removed. Instead, use `terraform apply -replace` for similar behavior*
```bash
terraform apply -replace="aws_instance.example"
```
