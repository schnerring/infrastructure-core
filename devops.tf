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

# Export credentials as GitHub Actions secrets
resource "github_actions_secret" "gh_secret_az_sp_client_id" {
  repository      = "infrastructure"
  secret_name     = "AZ_SP_CLIENT_ID"
  plaintext_value = azuread_application.devops_infrastructure_sp_app.application_id
}

resource "github_actions_secret" "gh_secret_az_sp_client_secret" {
  repository      = "infrastructure"
  secret_name     = "AZ_SP_CLIENT_SECRET"
  plaintext_value = azuread_service_principal_password.devops_infrastructure_sp_password.value
}

resource "github_actions_secret" "gh_secret_az_subscription_id" {
  repository      = "infrastructure"
  secret_name     = "AZ_SUBSCRIPTION_ID"
  plaintext_value = data.azurerm_subscription.subscription.subscription_id
}

resource "github_actions_secret" "gh_secret_az_tenant_id" {
  repository      = "infrastructure"
  secret_name     = "AZ_TENANT_ID"
  plaintext_value = data.azurerm_subscription.subscription.tenant_id
}
