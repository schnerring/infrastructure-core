<#
.SYNOPSIS
  Get all secrets from Azure Key Vault and map them to PowerShell environment
  variables.
.PARAMETER KeyVault
  Name of the Azure Key Vault.
.PARAMETER Subscription
  Name of the Azure subscription. If omitted, the default subscription is
  selected.
#>
param (
  [Parameter(Mandatory, HelpMessage="Name of the Azure Key Vault")]
  [string]
  $KeyVault,

  [Parameter(HelpMessage="Name of the Azure subscription")]
  [string]
  $Subscription
)

$ErrorActionPreference = "Stop"

Write-Information "Logging into Azure ..."
if ($Subscription) {
  Connect-AzAccount -Subscription $Subscription
} else {
  Connect-AzAccount
}

Write-Information "Geting secret list from Key Vault: $KeyVault ..."
$secrets = Get-AzKeyVaultSecret -VaultName $KeyVault -Name "*"

$i = 1;
foreach ($secret in $secrets) {
  $percentComplete = $i/$secrets.Count*100
  Write-Progress "Mapping secrets to environment variables ..." -Status $envVarName -PercentComplete $percentComplete
  $secretValuePlain = Get-AzKeyVaultSecret -VaultName $KeyVault -Name $secret.Name -AsPlainText
  $envVarName = $secret.Name.Replace("-", "_")
  Set-Item -Path env:$envVarName -Value $secretValuePlain
  $i++
}
