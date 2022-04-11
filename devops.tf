# Resources like Service Principals (SP), Key Vaults, and RBAC, used by GitHub
# Actions workflows for authentication and secrets management.

resource "azurerm_resource_group" "devops" {
  name     = "devops-rg"
  location = var.location
  tags     = var.tags
}

################################################################################
# infrastructure-core resources
# https://github.com/schnerring/infrastructure-core
################################################################################

resource "azurerm_key_vault" "infrastructure_core" {
  name                = "infracorekv${random_id.random.dec}"
  location            = azurerm_resource_group.devops.location
  resource_group_name = azurerm_resource_group.devops.name
  tenant_id           = data.azurerm_subscription.subscription.tenant_id
  tags                = var.tags

  sku_name                  = "standard"
  enable_rbac_authorization = true
}

# Azure Service Principal (SP), used by GitHub Actions and authorized to manage any Azure resource

resource "azuread_application" "infrastructure_core" {
  display_name = "gh-infrastructure-core-sp-app"
}

resource "azuread_service_principal" "infrastructure_core" {
  application_id = azuread_application.infrastructure_core.application_id
  tags           = ["DevOps", "gh-infrastructure-core"]
}

resource "azuread_service_principal_password" "infrastructure_core" {
  service_principal_id = azuread_service_principal.infrastructure_core.id

  rotate_when_changed = {
    rotation = time_rotating.sp_password_rotation_interval.id
  }
}

# Authorize SP to manage any Azure resource
resource "azurerm_role_assignment" "infrastructure_core_owner_role" {
  scope                = data.azurerm_subscription.subscription.id
  role_definition_name = "Owner"
  principal_id         = azuread_service_principal.infrastructure_core.id
}

# Export SP credentials as GitHub Actions secrets
resource "github_actions_secret" "infrastructure_core_az_sp_client_id" {
  repository      = "infrastructure-core"
  secret_name     = "AZ_SP_CLIENT_ID"
  plaintext_value = azuread_application.infrastructure_core.application_id
}

resource "github_actions_secret" "infrastructure_core_az_sp_client_secret" {
  repository      = "infrastructure-core"
  secret_name     = "AZ_SP_CLIENT_SECRET"
  plaintext_value = azuread_service_principal_password.infrastructure_core.value
}

resource "github_actions_secret" "infrastructure_core_az_subscription_id" {
  repository      = "infrastructure-core"
  secret_name     = "AZ_SUBSCRIPTION_ID"
  plaintext_value = data.azurerm_subscription.subscription.subscription_id
}

resource "github_actions_secret" "infrastructure_core_az_tenant_id" {
  repository      = "infrastructure-core"
  secret_name     = "AZ_TENANT_ID"
  plaintext_value = data.azurerm_subscription.subscription.tenant_id
}
