variable "plausible_db" {
  type = string
}

variable "plausible_username" {
  type = string
}

variable "plausible_password" {
  type      = string
  sensitive = true
}

variable "matrix_synapse_db" {
  type = string
}

variable "matrix_synapse_username" {
  type = string
}

variable "matrix_synapse_password" {
  type      = string
  sensitive = true
}
