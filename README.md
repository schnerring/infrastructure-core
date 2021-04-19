# infrastructure

Terraform "Infrastructure as Code" (IaC) project to manage my personal cloud infrastructure

## Local Development

### Initialize

Initialize the [Terraform azurerm backend](https://www.terraform.io/docs/language/settings/backends/azurerm.html):

```shell
terraform init \
  -backend-config="resource_group_name=terraform-rg" \
  -backend-config="storage_account_name=tfinfrastructurest37" \
  -backend-config="container_name=infrastructure-stctn" \
  -backend-config="key=infrastructure.tfstate"
```

### Deploy

```shell
terraform plan -out infrastructure.tfplan
terraform apply infrastructure.tfplan
```
