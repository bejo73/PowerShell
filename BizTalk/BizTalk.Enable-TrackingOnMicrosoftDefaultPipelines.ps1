#
# BizTalk.Enable-TrackingOnMicrosoftDefaultPipelines.ps1
# ------------------------------------------------------
#
# Description
# -----------
# Enables the tracking on the Microsoft Default pipelines (global)
#
# Usage
# -----
# BizTalk.Enable-TrackingOnMicrosoftDefaultPipelines.ps1
#

$silent = $false

$bizTalkSql = "."
$bizTalkMgmtDb = "BizTalkMgmtDb"

#
# CheckPipelines
#
function CheckPipelines($catalog)
{
    if (!$silent)
    {
        Write-Host `r`n===================================
        Write-Host "===   Check pipeline tracking   ==="
        Write-Host ===================================`r`n 
    }

    $saveChanges = $false
    foreach($pipeline in $catalog.Pipelines)
    {
        if ($pipeline.FullName -match "Microsoft.BizTalk.DefaultPipelines")
        {
            if (!$silent) { Write-Host $pipeline.FullName":`t"$pipeline.Tracking }
            
            # ServiceStartEnd, MessageSendReceive, InboundMessageBody, OutboundMessageBody, PipelineEvents
            
            if ($pipeline.Tracking -ne "ServiceStartEnd, MessageSendReceive, PipelineEvents")
            {
                if (!$silent) { Write-Host "Enabling tracking for "$pipeline.FullName -ForegroundColor Green }
                $pipeline.Tracking = "ServiceStartEnd, MessageSendReceive, PipelineEvents"
                $saveChanges = $true
            }
        }
    }
       
    if ($saveChanges)
    {
        $catalog.SaveChanges()
        if (!$silent) { Write-Host "Changes saved" }
    }
    
}

# Make sure the ExplorerOM assembly is loaded
[void] [System.reflection.Assembly]::LoadWithPartialName("Microsoft.BizTalk.ExplorerOM")

# Connect to the BizTalk Management database
$Catalog = New-Object Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer
$Catalog.ConnectionString = "SERVER=$bizTalkSql;DATABASE=$bizTalkMgmtDb;Integrated Security=SSPI"

# Do the work
CheckPipelines $Catalog
