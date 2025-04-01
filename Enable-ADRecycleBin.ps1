# Run this on a Domain Controller to enable AD Recycle Bin
# Nothing needs to be changed, will dynamically pull the domain information

function Get-RecycleBinStatus { Get-ADOptionalFeature -Filter {Name -like "Recycle*"} | Select-Object -ExpandProperty EnabledScopes }
if ([string]::IsNullOrWhitespace((Get-RecycleBinStatus))) {
	Write-Host "|| Enabling AD Recycle Bin..."
	Enable-ADOptionalFeature 'Recycle Bin Feature' -Scope ForestOrConfigurationSet -Target (Get-ADDomain | Select-Object -ExpandProperty DNSRoot) -Confirm:$false -WarningAction SilentlyContinue

	if (!([string]::IsNullOrWhitespace((Get-RecycleBinStatus)))) { Write-Host "|| - Successfully enabled AD Recycle Bin." }
	else { Write-Host "|| - Failed to enable AD Recycle Bin." }
} else {
	Write-Host "AD Recycle Bin already enabled."
}
