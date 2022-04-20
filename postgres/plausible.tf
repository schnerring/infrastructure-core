# Plausible Analytics DB

resource "postgresql_role" "plausible" {
  name     = var.plausible_username
  login    = true
  password = var.plausible_password
}

resource "postgresql_database" "plausible" {
  name  = var.plausible_db
  owner = postgresql_role.plausible.name
}
