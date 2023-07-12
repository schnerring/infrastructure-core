param (
  [Parameter(Mandatory, HelpMessage="Azure subscription ID")]
  [string]
  $SubscriptionId,

  [Parameter(HelpMessage="Reservation term duration in years (1 or 3)")]
  [int]
  $TermYears = 3,

  [Parameter(HelpMessage="Azure regions")]
  [string[]]
  $Locations = @(
    "canadaeast",
    "canadacentral",
    "eastus",
    "eastus2",
    "northeurope",
    "westeurope",
    "ukwest",
    "uksouth",
    "switzerlandnorth",
    "germanywestcentral",
    "francecentral",
    "norwayeast",
    "swedencentral"
  ),

  [Parameter(HelpMessage="CSV output filename")]
  [string]
  $OutFile = "VmReservationQuotes.csv"
)

function Get-VmLocation ($vmSize) {
  return $vmSize.Locations[0].ToLower()
}

function Test-VmCapability ($vmSize, $capabilityName, $capabilityValue) {
  foreach($capability in $vmSize.Capabilities)
  {
    if ($capability.Name -eq $capabilityName -and $capability.Value -eq $capabilityValue)
    {
      return $true
    }
  }
  return $false
}

$vmSizes = @()

foreach ($vmSize in Get-AzComputeResourceSku) {
  # Skip `availibilitySets`, `disks`, etc.
  if (-not ($vmSize.ResourceType -eq 'virtualMachines')) {
    continue
  }

  # Skip unavailable offers
  if ($vmSize.Restrictions.Count -gt 0) {
    continue
  }

  # Filter locations
  if (-not $Locations.Contains((Get-VmLocation $vmSize))) {
    continue
  }

  # Select D-Series VMs
  if (-not $vmSize.Name.StartsWith("Standard_D")) {
    continue
  }

  # Exclude confidential VMs
  if ($vmSize.Name.StartsWith("Standard_DC")) {
    continue
  }

  # Exclude memory-optimized VMs
  if ($vmSize.Name.StartsWith("Standard_D11") -or $vmSize.Name.StartsWith("Standard_DS11")) {
    continue
  }

  if (-not (Test-VmCapability $vmSize "EphemeralOSDiskSupported" "True")) {
    continue
  }

  if (-not (Test-VmCapability $vmSize "PremiumIO" "True")) {
    continue
  }

  if (-not (Test-VmCapability $vmSize "vCPUs" "2")) {
    continue
  }

  $vmSizes += $vmSize
}

$i = 0
foreach ($vmSize in $vmSizes) {
  $location = Get-VmLocation $vmSize
  $displayName = "$($vmSize.Name)-$location"

  # Progress Bar
  $i++
  $percent = [Math]::Floor(($i / $vmSizes.Count) * 100)
  Write-Progress -Activity "Requesting VM quotes" -Status "$percent% $displayName" -PercentComplete $percent

  $quote = Get-AzReservationQuote `
    -ReservedResourceType "VirtualMachines" `
    -Sku $vmSize.Name `
    -Location $location `
    -Term "P${TermYears}Y" `
    -BillingScopeId $SubscriptionId `
    -Quantity 1 `
    -AppliedScopeType Shared `
    -DisplayName "$displayName"

  # BillingCurrencyTotal is a JSON string, e.g.:
  # {
  #   "currencyCode": "CHF",
  #   "amount": 1130
  # }

  # Extract amount value `1130` from JSON
  $billingCurrencyTotal = $quote.BillingCurrencyTotal | ConvertFrom-Json
  $termPrice = $billingCurrencyTotal.amount

  @{
    Name = $vmSize.Name;
    Location = $location;
    PricePerMonth = $termPrice / ($TermYears * 12)
  } | Export-Csv -Path "${OutFile}" -NoTypeInformation -Delimiter ";" -Append
}
