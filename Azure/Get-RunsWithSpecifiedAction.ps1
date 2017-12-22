<#
 # Get-RunsWithSpecifiedAction.ps1 
 #
 # This script prints out a list of the lates runs where the specified action was successfull.
 # It can be used to check whether content has passed through a Logic App or not.
 # Default is last 31 days and 1000 rows in result.
 #
 # Parameters: ResourceGroup - The name of the resource group where the OMS workspace is located
 #             Workspace     - The name of the OMS workspace
 #             Workflow      - The name of the Logic App workflow
 #             Action        - The name of the actual action within the Logic App
 #             Top           - The maximum number of rows to be returned
 #             To            - End date (most recent runs)
 #             From          - Start date (oldest runs)
 # 
 # Usage: .\Get-RunsWithSpecifiedAction.ps1 -ResourceGroup MyResourceGroup -Workspace MyWorkspace -Workflow MyLogicApp -Action Get_file_content_using_path
 #
 #        Runs from last week:
 #        .\Get-RunsWithSpecifiedAction.ps1 -ResourceGroup MyResourceGroup -Workspace MyWorkspace -Workflow MyLogicApp -Action Get_file_content_using_path -To 0 -From -7
 #
 #        Get the 10 latest runs from last two weeks:
 #        .\Get-RunsWithSpecifiedAction.ps1 -ResourceGroup MyResourceGroup -Workspace MyWorkspace -Workflow MyLogicApp -Action Get_file_content_using_path -To 0 -From -14 -Top 10
 #>
 param ([Parameter(Mandatory=$true)][string] $ResourceGroup,
        [Parameter(Mandatory=$true)][string] $Workspace,
        [Parameter(Mandatory=$true)][string] $Workflow,
        [Parameter(Mandatory=$true)][string] $Action,
        [Parameter()][int] $Top = 1000,
        [Parameter()][int] $To = 0,
        [Parameter()][int] $From = -31
        )

$query = "Type=AzureDiagnostics And resource_workflowName_s=$Workflow And resource_actionName_s=$Action And status_s=Succeeded"

$date = $(get-date)
$end = $date.AddDays($To)
$start = $date.AddDays($From)

$result = Get-AzureRmOperationalInsightsSearchResults -ResourceGroupName $ResourceGroup -Workspace $Workspace -Query $query -End $end -Start $start -Top $Top

$result.Error.Message
$searchResults = $result.Value

Write-Host ""
foreach ($sr in $searchResults)
{
    $srObj = $sr | ConvertFrom-Json

    $logicApp  = $srObj.resource_workflowName_s
    $status    = $srObj.status_s
    $runId     = $srObj.resource_runId_s
    $action    = $srObj.resource_actionName_s
   
    $startTime = $srObj.startTime_t
    $d = $(Get-Date $startTime).ToLocalTime().ToString("yyyy-MM-dd HH:mm:ss")
    
   Write-Host "$d $logicApp $action $status $runId"
}
Write-Host ""