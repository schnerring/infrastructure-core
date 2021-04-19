# infrastructure

Terraform "Infrastructure as Code" (IaC) project to manage my personal cloud infrastructure

## Local Development

## Environment Variables

To authenticate to Azure, a service principal with subscription _Owner_ permissions is required. Set the following variables to [configure authentication](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret#configuring-the-service-principal-in-terraform):

- `ARM_CLIENT_ID`
- `ARM_CLIENT_SECRET`
- `ARM_SUBSCRIPTION_ID`
- `ARM_TENANT_ID`

To authenticate to GitHub, set the `GITHUB_TOKEN` variable to a [personal access token](https://docs.github.com/en/rest/overview/other-authentication-methods#basic-authentication) with _public_repo_ scope.

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
