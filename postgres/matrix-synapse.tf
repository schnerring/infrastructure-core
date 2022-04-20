# Matrix Synapse DB

resource "postgresql_role" "matrix_synapse" {
  name     = var.matrix_synapse_username
  login    = true
  password = var.matrix_synapse_password
}

# See https://github.com/matrix-org/synapse/blob/master/docs/postgres.md#set-up-database
resource "postgresql_database" "matrix_synapse" {
  name       = var.matrix_synapse_db
  owner      = postgresql_role.matrix_synapse.name
  encoding   = "UTF8"
  lc_collate = "C"
  lc_ctype   = "C"
  template   = "template0"
}
