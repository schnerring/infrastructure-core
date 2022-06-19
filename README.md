# infrastructure

This project contains the configuration for my cloud infrastructure, for which I use [Terraform](https://www.terraform.io/), an open-source infrastructure-as-code tool.

## Local Development

### Connect to Postgres

This project also manages Postgres databases. Before being able to apply changes, connect to Postgres by running:

```shell
kubectl port-forward service/postgres-svc --namespace postgres 5432:5432
```

### Authentication

[Use the Azure CLI to authenticate to Azure](https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/azure_cli) to interactively run Terraform:

```shell
az login
```

For GitHub and Cloudflare, use [personal access tokens (PAT)](https://docs.github.com/en/rest/overview/other-authentication-methods#basic-authentication) and put them into the following environment variables:

- `GITHUB_TOKEN` with `public_repo` scope
- `CLOUDFLARE_API_TOKEN` with `Zone.Zone` and `Zone.DNS` permissions.

### Terraform Input Variables

Terraform input variables to configure the deployment are defined inside the [variables.tf](./variables.tf) file.

Use the `tfinfracorekv37` key vault to store sensitive Terraform variable values. It enhances operational security because storing secrets in plaintext files or environment variables can be avoided. The [map-kv-to-env-vars.ps1](./map-kv-to-env-vars.ps1) convenience script maps the `TF-VAR-*` key vault secrets to `TF_VAR_*` environment variables. The mappings are not persisted and are only available within the PowerShell session that executed the script.

```powershell
.\map-kv-to-env-vars.ps1 -KeyVault tfinfracorekv37
```

To access the key vault, the user requires the following role assignments:

- `Key Vault Administrator` and `Key Vault Secrets Officer` roles to manage secrets
- `Key Vault Secrets User` to read secrets

I like to manage these role assignments with the Azure Portal and not add them to the Terraform state.

### Initialize the Terraform Backend

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

The configuration is split into three Terraform modules because the [official Kubernetes provider documentation discourages](https://registry.terraform.io/providers/hashicorp/kubernetes/latest/docs#stacking-with-managed-kubernetes-cluster-resources) stacking Kubernetes cluster infrastructure with Kubernetes resources.

Each module contains the following base files:

| File           | Description                                                                               |
| -------------- | ----------------------------------------------------------------------------------------- |
| `main.tf`      | Terraform requirements and shared module resources                                        |
| `outputs.tf`   | [Terraform Outputs](https://www.terraform.io/docs/language/values/outputs.html)           |
| `variables.tf` | [Terraform Input Variables](https://www.terraform.io/docs/language/values/variables.html) |

### Core

Core infrastructure.

| File                                                  | Description                                                                                                                                                  |
| ----------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| [`aks.tf`](./core/k8s.tf)                             | Azure Kubernetes Service (AKS) cluster resources                                                                                                             |
| [`backup-truenas.tf`](./core/backup-truenas.tf)       | Azure storage account containers used for TrueNAS cloud sync tasks                                                                                           |
| [`backup.tf`](./core/backup.tf)                       | Azure backup vault to protect blob storage for Terraform state                                                                                               |
| [`cloudflare.tf`](./core/cloudflare.tf)               | Common Cloudflare DNS records and Page Rules                                                                                                                 |
| [`terraform-backend.tf`](./core/terraform-backend.tf) | Azure storage configuration for [Terraform Remote State](https://www.terraform.io/docs/language/state/remote.html) and Azure Key Vault for Terraform secrets |

### Kubernetes

Kubernetes resources that are stacked on top of the AKS cluster defined in the `core` module.

| File                                        | Description                                                                                                                                                       |
| ------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`hello.tf`](./kubernetes/hello.tf)         | "Hello World" AKS deployment                                                                                                                                      |
| [`matrix.tf`](./kubernetes/matrix.tf)       | [Matrix Synapse homeserver](https://github.com/matrix-org/synapse/) and [Synpase Admin UI](https://github.com/Awesome-Technologies/synapse-admin) AKS deployments |
| [`plausible.tf`](./kubernetes/plausible.tf) | [Plausible Analytics](https://plausible.io/) AKS deployment                                                                                                       |
| [`postgres.tf`](./kubernetes/postgres.tf)   | [PostgreSQL](https://www.postgresql.org/) AKS deployment                                                                                                          |
| [`remark42.tf`](./kubernetes/remark42.tf)   | [Remark42](https://remark42.com/) AKS deployment                                                                                                                  |

### PostgreSQL

PostgreSQL resources that are stacked on top of the PostgreSQL deployment defined in the `kubernetes` module.

| File                                                | Description                      |
| --------------------------------------------------- | -------------------------------- |
| [`matrix-synapse.tf`](./postgres/matrix-synapse.tf) | Matrix Synapse database and user |
| [`plausible.tf`](./postgres/plausible.tf)           | Plausible database and user      |

## Related Repositories

To back up the Kubernetes Services (Matrix Synapse, Plausible, Remark42), I run a custom set of scripts with cron on my TrueNAS daily. You can find the scripts in the following repo:

[https://github.com/schnerring/k8s-backup-scripts](https://github.com/schnerring/k8s-backup-scripts)
