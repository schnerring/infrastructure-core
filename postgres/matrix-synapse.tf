# Matrix Synapse DB

resource "random_password" "synapse" {
  length = 64
}

resource "postgresql_role" "synapse" {
  name     = "synapse_user"
  login    = true
  password = random_password.synapse.result
}

# See https://github.com/matrix-org/synapse/blob/master/docs/postgres.md#set-up-database
resource "postgresql_database" "synapse" {
  name       = "synapse"
  owner      = postgresql_role.synapse.name
  encoding   = "UTF8"
  lc_collate = "C"
  lc_ctype   = "C"
  template   = "template0"
}
