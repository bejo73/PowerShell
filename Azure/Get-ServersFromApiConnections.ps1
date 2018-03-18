<#
 # Get-ServersFromApiConnections.ps1 
 #
 # This script prints out a list of the servers from the API Connecitons in the acutal Azure Subscription.
 #
 # Usage: .\Get-ServersFromApiConnections.ps1
 #
 #>

$uniqueEndpoints = @{}
$resources = Get-AzureRmResource
$count = 1
$context = Get-AzureRmContext
$subscriptionName = $context.SubscriptionName

foreach ($r in $resources)
{
    # Progress bar
    Write-Progress -Activity "Gathering Azure Resources from subscripton $subscriptionName" -Status "Found resource $count" -PercentComplete ($count / $resources.count*100)
    $count++

    # API Connections
    if ($r.ResourceType -eq 'Microsoft.Web/connections')
    {
        $resource   = Get-AzureRmResource -ResourceId $r.ResourceId
        $properties = $resource.Properties
        $api        = $properties.api
        $apiName    = $api.name
        $parameters = $properties.nonSecretParameterValues
        $endpoint     = $null

        switch ($apiName)
        {
            filesystem
            {
                $uri    = new-object System.Uri($parameters.rootfolder)
                $endpoint = $uri.host

                if ($endpoint.Length -eq 0)
                {
                    $endpoint = $parameters.rootfolder
                }
            }
            ftp
            {
                $endpoint = $parameters.serverAddress
            }
            sftp
            {
                $endpoint = $parameters.hostName
            }
            sql
            {
                $endpoint   = $parameters.server
            }
            office365
            {
                $endpoint = $properties.displayName
            }
            outlook
            {
                $endpoint = $properties.displayName
            }
            smtp
            {
                $endpoint = $parameters.serverAddress
            }
            oracle
            {
                $endpoint = $parameters.server
            }
            azureblob
            {
                $endpoint = $parameters.accountName
            }
            servicebus
            {
                $endpoint = $properties.displayName
            }
            biztalk
            {
                $endpoint = $properties.displayName
            }
            gmail
            {
                $endpoint = $properties.displayName
            }
            teams
            {
                $endpoint = $properties.displayName
            }
            azuread
            {
                $endpoint = $properties.displayName
            }
            default
            {
                $apiName
            }

        }

        if ($endpoint -ne $null)
        {
            if (!$uniqueEndpoints.ContainsKey($endpoint))
            {
                $uniqueEndpoints.Add($endpoint, $apiName)
            }
        }
    }
}

# List unique endpoints
foreach ($ue in $uniqueEndpoints.Keys)
{
    $type = $uniqueEndpoints[$ue]
    Write-host "$ue, $type"
}