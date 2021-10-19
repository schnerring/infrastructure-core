# Azure Service Principal (SP), used by GitHub Actions and authorized to manage any Azure resource

resource "azuread_application" "devops_infrastructure" {
  display_name = "devops-infrastructure-sp-app"
}

resource "azuread_service_principal" "devops_infrastructure" {
  application_id = azuread_application.devops_infrastructure.application_id
  tags           = ["DevOps", "infrastructure"]
}

resource "azuread_service_principal_password" "devops_infrastructure" {
  service_principal_id = azuread_service_principal.devops_infrastructure.id

  rotate_when_changed = {
    rotation = time_rotating.sp_password_rotation_interval.id
  }
}

# Authorize to manage any Azure resource and RBAC
resource "azurerm_role_assignment" "devops_infrastructure_owner_role_assignment" {
  scope                = data.azurerm_subscription.subscription.id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.devops_infrastructure.id
}

# Export credentials as GitHub Actions secrets
resource "github_actions_secret" "gh_secret_az_sp_client_id" {
  repository      = "infrastructure"
  secret_name     = "AZ_SP_CLIENT_ID"
  plaintext_value = azuread_application.devops_infrastructure.application_id
}

resource "github_actions_secret" "gh_secret_az_sp_client_secret" {
  repository      = "infrastructure"
  secret_name     = "AZ_SP_CLIENT_SECRET"
  plaintext_value = azuread_service_principal_password.devops_infrastructure.value
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
