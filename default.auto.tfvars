location     = "Switzerland North"
aks_location = "East US"

tags = {
  "Environment"          = "Production"
  "Management Framework" = "Terraform"
  "Project"              = "infrastructure"
}

cert_manager_helm_chart_version = "v1.8.0"
traefik_helm_chart_version      = "10.19.4"
clickhouse_image_version        = "21.8.14.5" # LTS release: https://hub.docker.com/r/yandex/clickhouse-server/tags?page=1&name=21.8.14
postgres_image_version          = "14.2"
plausible_image_version         = "v1.4.4"
remark42_image_version          = "v1.9.0"
matrix_synapse_image_version    = "v1.55.0"

plausible_db          = "plausible"
plausible_db_username = "plausible_user"

matrix_synapse_db          = "matrix-synapse"
matrix_synapse_db_username = "matrix-synapse_user"
