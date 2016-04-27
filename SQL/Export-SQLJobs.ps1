# This path will probably differ between environments
Add-Type -Path 'C:\Program Files (x86)\Microsoft SQL Server\100\SDK\Assemblies\Microsoft.SqlServer.Smo.dll'

$serverInstances = @("MYSQLSERVER", "MYSQLSERVER\INSTANCE")
 
foreach ($serverInstance in $serverInstances)
{
   $server = New-Object ('Microsoft.SqlServer.Management.Smo.Server') $serverInstance
 
   $jobs = $server.JobServer.Jobs 

   if ($jobs -ne $null)
   {
      $serverInstance = $serverInstance.Replace("\", "-")
 
      foreach ($job in $jobs)
      {
         $fileName = "\\exportpath\" + $serverInstance + "_" + $job.Name + ".sql"
         $job.Script() | Out-File -Filepath $fileName
      }
   }
}
