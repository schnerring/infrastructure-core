variable "location" {
  type        = string
  description = "Azure datacenter location where resources will be deployed to."
  default     = "Switzerland North"
}

variable "tags" {
  type        = map(string)
  description = "Default Azure tags applied to any resource."
  default = {
    "Environment"          = "Production"
    "Management Framework" = "Terraform"
    "Project"              = "infrastructure"
  }
}
