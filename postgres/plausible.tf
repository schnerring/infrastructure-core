# Plausible Analytics DB

resource "random_password" "plausible" {
  length = 64
}

resource "postgresql_role" "plausible" {
  name     = "plausible"
  login    = true
  password = random_password.plausible.result
}

resource "postgresql_database" "plausible" {
  name  = "plausible"
  owner = postgresql_role.plausible.name
}
