location     = "Switzerland North"
aks_location = "East US"

tags = {
  "Environment"          = "Production"
  "Management Framework" = "Terraform"
  "Project"              = "infrastructure"
}

cert_manager_helm_chart_version = "v1.14.1"
traefik_helm_chart_version      = "26.0.0"
clickhouse_image_version        = "22.6-alpine"
postgres_image_version          = "14-alpine"
plausible_image_version         = "v2.0.0"
remark42_image_version          = "v1.12.1"
matrix_synapse_image_version    = "v1.79.0"

plausible_db          = "plausible"
plausible_db_username = "plausible_user"

matrix_synapse_db          = "matrix-synapse"
matrix_synapse_db_username = "matrix-synapse_user"
