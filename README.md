# Infrastructure
> This infrastructure instantiate required components in order to operate the a tenant

# How to provision?
1. Fill in the .tfvars file with values in (.tfvars.example)[./.tfvars.example]
2. Run planning to preview input, output, infrastructure

```
terraform plan -var-file .tfvars
```
3. Run apply to provision infrastructure

```
terraform apply -var-file .tfvars
```
4. Destroy ifnrastructure

```
terraform destroy -var-file .tfvars
```

# Outputs
```
terraform output
```
