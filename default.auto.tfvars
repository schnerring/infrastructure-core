location     = "Switzerland North"
aks_location = "East US"

tags = {
  "Environment"          = "Production"
  "Management Framework" = "Terraform"
  "Project"              = "infrastructure"
}

clickhouse_image_version     = "21.3.9.83" # LTS release: https://github.com/ClickHouse/ClickHouse/releases/tag/v21.3.9.83-lts
postgres_image_version       = "13.3"
plausible_image_version      = "v1.4.4"
remark42_image_version       = "v1.9.0"
matrix_synapse_image_version = "v1.55.0"

plausible_db          = "plausible"
plausible_db_username = "plausible" # TODO change to "plausible_user"

matrix_synapse_db          = "synapse"
matrix_synapse_db_username = "synapse_user"
