#
# BizTalk.Enable-TrackingOnMicrosoftDefaultPipelines.ps1
# ------------------------------------------------------
#
# Description
# -----------
# Enables the tracking on the Microsoft Default pipelines (global)
#  
# Prerequisites
# -------------
# The BizTalk connection string is declared in $BIZTALK_CONNECTIONSTRING (suggested in profile.ps1)
#
# Usage
# -----
# iBiz.BizTalk.Enable-TrackingOnMicrosoftDefaultPipelines.ps1
#

#
# CheckPipelines
#
Function CheckPipelines($catalog)
{
    Write-Host `r`n===================================
    Write-Host "===   Check pipeline tracking   ==="
    Write-Host ===================================`r`n 

    $saveChanges = 0
    foreach($pipeline in $catalog.Pipelines)
    {
        if ($pipeline.FullName -match "Microsoft.BizTalk.DefaultPipelines")
        {
            Write-Host $pipeline.FullName":`t"$pipeline.Tracking
            
            # ServiceStartEnd, MessageSendReceive, InboundMessageBody, OutboundMessageBody, PipelineEvents
            
            if ($pipeline.Tracking -ne "ServiceStartEnd, MessageSendReceive, PipelineEvents")
            {
                Write-Host "Enabling tracking for "$pipeline.FullName
                $pipeline.Tracking = "ServiceStartEnd, MessageSendReceive, PipelineEvents"
                $saveChanges = 1
            }
        }
    }
     
    if ($saveChanges -eq 1)
    {
        $catalog.SaveChanges();
        Write-Host "Changes saved"
    }
    
}

# Make sure the ExplorerOM assembly is loaded
[void] [System.reflection.Assembly]::LoadWithPartialName("Microsoft.BizTalk.ExplorerOM")

# Connect to the BizTalk Management database
$Catalog = New-Object Microsoft.BizTalk.ExplorerOM.BtsCatalogExplorer
$Catalog.ConnectionString = $BIZTALK_CONNECTIONSTRING

# Do the work
CheckPipelines $Catalog
