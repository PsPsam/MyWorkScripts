[CmdletBinding(SupportsShouldProcess=$true)]
Param()
import-module -Name sqlserver -DisableNameChecking

$sqlcommand = @'
SELECT CS.replica_server_name,C.[name], RS.role_desc, RS.connected_state_desc, RS.synchronization_health_desc, AR.secondary_role_allow_connections_desc
    FROM sys.availability_groups_cluster AS C
        INNER JOIN sys.dm_hadr_availability_replica_cluster_states AS CS
            ON CS.group_id = C.group_id
        INNER JOIN sys.dm_hadr_availability_replica_states AS RS
            ON RS.replica_id = CS.replica_id
		INNER JOIN sys.availability_replicas AS AR
			ON AR.replica_server_name = CS.replica_server_name
'@



$servers = Invoke-Sqlcmd -Query $sqlcommand -ServerInstance 'vax-cl420-axacc.sodra.com'

$primary = @()
$secondarys = @()
$readonlys = @()

foreach ($server in $servers)
{
    Write-Verbose -Message "Checking on serverobject: $($server.replica_server_name)"
    if ($server.role_desc -like 'Secondary' -and $server.secondary_role_allow_connections_desc -like 'Read_Only')
    {
        $secondarys += $server.replica_server_name
        Write-verbose -Message "ReadOnly server: $($server.replica_server_name)"
    }
    Elseif ($server.role_desc -like 'Secondary' -and $server.secondary_role_allow_connections_desc -like 'No')
    {
        $readonlys += $server.replica_server_name
        Write-verbose -Message "Secondary server:  $($server.replica_server_name)"
    }
    Elseif ($server.role_desc -like 'Primary')
    {
        $primary = $server.replica_server_name
        Write-verbose -Message "Primary server:  $($server.replica_server_name)"
    }
}


if ($readonlys)
{
    # install missing updates for each Read_Only server
    # wait for AG to be healthy
    # When do we say that the installation has failed and that the AO group isnt comming back online?
    $Health = $false
    do {
        Start-Sleep -Seconds 30
        $Healths = Get-ChildItem -Path SQLSERVER:\Sql\$Primary\Default\AvailabilityGroups | Test-SqlAvailabilityGroup
        foreach ($H in $healths) {
           if ($H.HealthState -eq 'Healthy') 
           {
                $Health = $true
           }
           ElseIf ($H.HealthState -ne 'Healthy')
           {
                $Health = $false
           }
        }
    } while ($Health -eq $false)
}

if ($secondarys)
{
    #install missing updates for each secondary server
    #wait for AG to be healthy
}

if ($primary)
{
    #Do a failover from primary to secondary server
    #install missing updates for the former Primary server
    #wait for AG to be healthy
    #Fail over so that we are back to the way we where before the installation of patches
}