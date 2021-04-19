# Azure Service Principal (SP), used by GitHub Actions and authorized to manage any Azure resource

resource "azuread_application" "devops_infrastructure_sp_app" {
  display_name = "devops-infrastructure-sp-app"
}

resource "azuread_service_principal" "devops_infrastructure_sp" {
  application_id = azuread_application.devops_infrastructure_sp_app.application_id
  tags           = ["DevOps", "infrastructure"]
}

# TODO: configure automatic GitHub action to renew password before expiry
resource "random_password" "devops_infrastructure_sp_random_password" {
  keepers = {
    expiry = time_rotating.sp_password_rotation_interval.rotation_rfc3339
  }
  length = 64
}

resource "azuread_service_principal_password" "devops_infrastructure_sp_password" {
  service_principal_id = azuread_service_principal.devops_infrastructure_sp.id
  description          = "Terraform managed password."
  value                = random_password.devops_infrastructure_sp_random_password.result
  end_date             = time_rotating.sp_password_rotation_interval.rotation_rfc3339
}

# Authorize to manage any Azure resource and RBAC
resource "azurerm_role_assignment" "devops_infrastructure_owner_role_assignment" {
  scope                = data.azurerm_subscription.subscription.id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.devops_infrastructure_sp.id
}
