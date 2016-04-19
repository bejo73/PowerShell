#
# BizTalk.Export.Bindings_And_MSIs.ps1
# -----------------------------------------
#
# Description
# -----------
# Exports BizTalk application MSI's (without binding and party information), bindings and resource specifications
#  
# Prerequisites
# -------------
# BizTalkFactory PowerShell Provider (1.2.0.4 or above) is required.
# More information: http://http://psbiztalk.codeplex.com/
#
# Usage
# -----
# This example exports all applications to "C:\temp" where Invoice is included in the application name
#
# Ex: BizTalk.Export.Bindings_And_MSIs.ps1 -Filter Invoice -ExportFolder "C:\temp" 
#
# MSI's are exported to                   C:\temp\MSI
# Bindings are exported to                C:\temp\Bindings
# Resource specifications are exported to C:\temp\ResourceSpec
#
# Leaving the parameter filter will export all applications on the BizTalk server.
# Levaing the parameter exportFolder will export the applications to the current folder.
#
# Parameters
# ----------
# Filter: Filter which applications to export, wildcards supported. 
# ExportFolder: The folder where the MSI's, bindings and resource specificaitons are exported.
#
param([string]$filter, [string]$exportFolder)

# Check parameter filter
if ($filter.Equals(""))
{
    $filter = "*"
}
else
{
    $filter = "*$filter*"
}

# Check parameter export folder
if ($exportFolder.Equals(""))
{
    $exportFolder = "."
}

$msi               = $exportFolder + "\MSI"
$bindings          = $exportFolder + "\Bindings"
$resourceSpec      = $exportFolder + "\ResourceSpec"
$tmpResSpec        = $exportFolder + "\tmpResSpec.xml"
$resSpecNoBindings = $exportFolder + "\resSpecNoBindings.xml"

$applications = Get-Item "BizTalk:\Applications\$filter"

foreach($application in $applications)
{
   $name = $application.Name

   Write-Host "Exporting $name.msi"

   # Get resource specification for application
   (Get-ApplicationResourceSpec -Path BizTalk:\Applications\$name).OuterXml | Out-File $tmpResSpec

   # Export bindings
   Export-Bindings -Path BizTalk:\Applications\$name -Destination "$bindings\$name.xml"

   # Remove bindings from resource file
   Get-Content $tmpResSpec | foreach-Object { [regex]::replace($_, '<Resource Type="System.BizTalk:BizTalkBinding" Luid="[./A-Za-z0-9]*" />', "") } | out-file "$resSpecNoBindings"

   # Export MSI without bindings
   Export-Application -Path BizTalk:\Applications\$name -Package "$msi\$name.msi" -ResourceSpec $resSpecNoBindings

   # Save application resource specification (without binding information)
   New-Item -ItemType directory -Path "$resourceSpec" -Force | Out-Null
   Move-Item $resSpecNoBindings "$resourceSpec\$name.xml" -Force
	
   # Clean
   Remove-Item $tmpResSpec
}