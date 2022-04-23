# infrastructure

This project contains the configuration for my cloud infrastructure, for which I use [Terraform](https://www.terraform.io/), an open-source infrastructure-as-code tool.

## Local Development

### Connect to Postgres

This project also manages Postgres databases. Before being able to apply changes, connect to Postgres by running:

```shell
kubectl port-forward service/postgres-svc --namespace postgres 5432:5432
```

### Environment Variables

[Use the Azure CLI to authenticate to Azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli) to interactively run Terraform:

```shell
az login
```

To authenticate with GitHub, set the `GITHUB_TOKEN` variable to a [personal access token (PAT)](https://docs.github.com/en/rest/overview/other-authentication-methods#basic-authentication) with `public_repo` scope.

To authenticate to Cloudflare, set the `CLOUDFLARE_API_TOKEN` variable to a personal access token with `Zone.Zone` and `Zone.DNS` permissions.

Terraform input variables to configure the deployment are defined inside the [variables.tf](./variables.tf) file. Use the `tfinfracorekv37` key vault stores Terraform variable values. It enhances operational security because storing secrets in plaintext files or environment variables can be avoided. The [map-kv-to-env-vars.ps1](./map-kv-to-env-vars.ps1) convenience script maps the `TF-VAR-*` key vault secrets to `TF_VAR_*` environment variables. These mappings are not persisted and only available inside the PowerShell session that executed the script.

```powershell
.\map-kv-to-env-vars.ps1 -KeyVault tfinfracorekv37
```

To access the key vault, the user requires the following role assignments:

- `Key Vault Administrator` and `Key Vault Secrets Officer` roles to manage secrets
- `Key Vault Secrets User` to read secrets

I like to manage these assignments with the Azure Portal and not Terraform.

### Initialize

Initialize the [Terraform azurerm backend](https://www.terraform.io/docs/language/settings/backends/azurerm.html):

```shell
terraform init \
  -backend-config="resource_group_name=terraform-rg" \
  -backend-config="storage_account_name=tfinfracorest37" \
  -backend-config="container_name=terraform-backend" \
  -backend-config="key=infrastructure-core.tfstate"
```

### Deploy

```shell
terraform plan -out infrastructure-core.tfplan
terraform apply infrastructure-core.tfplan
```

## Replace the AKS cluster and re-create the Kubernetes resources

```shell
terraform destroy -target module.postgres
terraform destroy -target module.kubernetes
terraform apply -target module.kubernetes.helm_release.cert_manager #CRDs
terraform apply -target module.kubernetes
terraform apply
```

## Terraform Resource Overview

| File                                       | Description                                                                                                                                                       |
| :----------------------------------------- | :---------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`common.tf`](./common.tf)                 | Common resources that is shared between deployments                                                                                                               |
| [`backend.tf`](./backend.tf)               | [Remote State](https://www.terraform.io/docs/language/state/remote.html) configuration                                                                            |
| [`provider.tf`](./provider.tf)             | [Provider](https://www.terraform.io/docs/language/providers/index.html) configuration                                                                             |
| [`terraform.tf`](./terraform.tf)           | Remote State storage configuration                                                                                                                                |
| [`variables.tf`](./variables.tf)           | [Input Variables](https://www.terraform.io/docs/language/values/variables.html)                                                                                   |
| [`outputs.tf`](./outputs.tf)               | [Output Values](https://www.terraform.io/docs/language/values/outputs.html)                                                                                       |
| [`truenas-backup.tf`](./truenas-backup.tf) | Azure Storage Account configuration that is used by my TrueNAS as backup storage                                                                                  |
| [`cloudflare.tf`](./cloudflare.tf)         | Common Cloudflare DNS records and Page Rules                                                                                                                      |
| [`devops.tf`](./devops.tf)                 | Azure Service Principal authorized to perform Terraform operations                                                                                                |
| [`hello.tf`](./hello.tf)                   | "Hello World" AKS deployment                                                                                                                                      |
| [`k8s.tf`](./k8s.tf)                       | Azure Kubernetes Service (AKS) cluster resources                                                                                                                  |
| [`matrix.tf`](./matrix.tf)                 | Matrix [Synapse homeserver](https://github.com/matrix-org/synapse/) and [Synpase Admin UI](https://github.com/Awesome-Technologies/synapse-admin) AKS deployments |
| [`plausible.tf`](./plausible.tf)           | [Plausible Analytics](https://plausible.io/) AKS deployment                                                                                                       |
| [`postgres.tf`](./postgres.tf)             | [PostgreSQL](https://www.postgresql.org/) AKS deployment                                                                                                          |
| [`remark42.tf`](./remark42.tf)             | [Remark42](https://remark42.com/) AKS deployment                                                                                                                  |

## Related Repositories

To back up the Kubernetes Services (Matrix Synapse, Plausible, Remark42), I run a custom set of scripts daily with cron on my TrueNAS. You can find the scripts in the following repo:

[https://github.com/schnerring/k8s-backup-scripts](https://github.com/schnerring/k8s-backup-scripts)
