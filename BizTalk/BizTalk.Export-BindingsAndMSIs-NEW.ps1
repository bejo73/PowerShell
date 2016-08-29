#
# BizTalk.Export.Bindings_And_MSIs.v2.0.ps1
# -----------------------------------------
#
# Description
# -----------
# Exports BizTalk application MSI's (without binding and party information), bindings and resource specifications
#
# Usage
# -----
# This example exports all applications to "C:\temp" where Invoice is included in the application name
#
# Ex: BizTalk.Export.Bindings_And_MSIs.ps1 -filter Invoice -exportFolder "C:\temp" 
#
# MSI's are exported to                   C:\temp\MSI
# Bindings are exported to                C:\temp\Bindings
# Resource specifications are exported to C:\temp\ResourceSpec
#
# Leaving the parameter filter will export all applications on the BizTalk server.
# Levaing the parameter exportFolder will export the applications to the current folder.
#
# Note: The application 'BizTalk.System' is not exported.
#
# Parameters
# ----------
# Filter: Filter which applications to export, wildcards supported. 
# ExportFolder: The folder where the MSI's, bindings and resource specificaitons are exported.
#
param([string]$filter, [string]$exportFolder)

$bizTalkGroupSetting = get-wmiobject MSBTS_GroupSetting -namespace root\MicrosoftBizTalkServer

$bizTalkSqlInstance = $bizTalkGroupSetting.MgmtDbServerName
$bizTalkMgmtDb      = $bizTalkGroupSetting.MgmtDbName

# Make sure the ExplorerOM assembly is loaded
[void] [System.reflection.Assembly]::LoadWithPartialName("Microsoft.BizTalk.ExplorerOM")

# Connect to the BizTalk Management database
$Catalog = New-Object Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer
$Catalog.ConnectionString = "SERVER=$bizTalkSqlInstance;DATABASE=$bizTalkMgmtDb;Integrated Security=SSPI"

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

$applications = $Catalog.Applications | ?{ ($_.Name -match $filter) -and ($_.Name -ne 'BizTalk.System') } 

foreach($application in $applications)
{
   $name = $application.Name

   Write-Host "Exporting $name"
   
   # Get resource specification for application
   $out = BTSTask ListApp "/ApplicationName:$name" "/ResourceSpec:$tmpResSpec" "/Server:$bizTalkSqlInstance" "/Database:$bizTalkMgmtDb"
   #$out

   # Export bindings
   $out = BTSTask ExportBindings "/Destination:$bindings\$name.xml"  "/ApplicationName:$name" "/Server:$bizTalkSqlInstance" "/Database:$bizTalkMgmtDb"
   #$out

   # Remove bindings from resource file
   Get-Content $tmpResSpec | foreach-Object { [regex]::replace($_, '<Resource Type="System.BizTalk:BizTalkBinding" Luid="[. /A-Za-z0-9]*" />', "") } | out-file "$resSpecNoBindings"

   # Export MSI without bindings
   $out = BTSTask ExportApp "/ApplicationName:$name" "/Package:$msi\$name.msi" "/ResourceSpec:$resSpecNoBindings" "/Server:$bizTalkSqlInstance" "/Database:$bizTalkMgmtDb"
   #$out

   # Save application resource specification (without binding information)
   New-Item -ItemType directory -Path "$resourceSpec" -Force | Out-Null
   Move-Item $resSpecNoBindings "$resourceSpec\$name.xml" -Force
	
   # Clean
   Remove-Item $tmpResSpec
}