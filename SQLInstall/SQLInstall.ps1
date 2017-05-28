##requires -Version 3 -Modules ActiveDirectory, GroupPolicy, SqlServer

Function Test-WSManCredSSP {
  # Enable double hop for Powershell (Is there a better way?)

  # Todo
  # Should add domain as imput parameter {
  if ((Get-Item  -Path WSMan:\localhost\Client\Auth\CredSSP).value -eq $false) {
    #enabla credspp
    Enable-WSManCredSSP -Role client -DelegateComputer *.Default.com
    try {
      Enable-WSManCredSSP -Role client -DelegateComputer *.Default.com -Force
    }
    catch {
      Write-Error -Message $_.Exception.Message
      Throw 'Enable-WSManCredSSP unsuccessfull'
    }
  }
  else {
    $true
  }
}  # Function Test Test-WSManCredSSP done

Function Test-WindowsFeature {
  # Check if the services exist and takes action based on that
  [CmdletBinding()]
  param(
    [String]$ComputerName, # Name of the server to check
    [String]$Name, # Features namne
    [ValidateSet('Install', 'Uninstall')] # What action to take
    [String]$Action
  )
  if ($Action -eq 'Install') {
    if ((Get-WindowsFeature -ComputerName $ComputerName -Name $Name -ErrorAction Ignore).installed) {

      Write-Verbose -Message "$ComputerName has $Name installed"
      Write-Output -InputObject "$ComputerName has feature $Name installed"
    }
    else {
      {

        Write-Verbose -Message "$ComputerName has $Name installed"
        Write-Output -InputObject "$ComputerName has feature $Name installed"
      }
      else 
      {
        Write-Verbose -Message "Installing $Name on $ComputerName"
        try {
          if (test-path $env:HOMEDRIVE\SXS) {
            Install-WindowsFeature -ComputerName $ComputerName -Name $Name -Source $env:HOMEDRIVE\SXS
            Write-Output -InputObject "$ComputerName got feature $Name installed"
          }
          else {
            Write-Output -InputObject "$ComputerName doesn't have SXS folder"
          }
        }
        catch {
          Write-Output -InputObject "$ComputerName failed to get feature $Name installed"
        }
      }
    } # Install action done
    elseif ($Action -eq 'Uninstall') 
    {
      if ((Get-WindowsFeature -ComputerName $ComputerName -Name $Name -ErrorAction Ignore).installed) {
        Write-Verbose -Message "$ComputerName has $Name installed, removing the feature"
        Try {
          Uninstall-WindowsFeature -ComputerName $ComputerName -Name $Name -IncludeManagementTools
          Write-Output -InputObject "$ComputerName got feature $Name removed"
        }
        catch {
          Write-Output -InputObject "$ComputerName failed to remove feature $Name"
        }
      }
      else {
        Write-Verbose -Message "$ComputerName does not have $Name installed"
        Write-Output -InputObject "$ComputerName does not have $Name installed"
      }
		
    } # Uninstall action done
  }
} #Function Test-WindowsFeature done

function Get-SQLBackupFolder {
  param(
    # Computername to check the SQL Backup directory
    [Parameter(Mandatory)]
    [String]$ComputerName,
		
    # Enviroment, Prod, Acc eller Test
    [Parameter(Mandatory)]
    [ValidateSet('Prod', 'Acc', 'Test')]
    [String]$env,
		
    # Base backupfolder
    [Parameter(Mandatory)]
    [String]$backupfolder
		
  )
    
  Write-Verbose "Switching pending on enviroment"	
  switch ($env) {
    'Prod' {
      Write-Verbose 'Prod'
      try {
        Add-ADGroupMember -Identity 'sec-sql-backup-prod-rw' -Members $ComputerName'$'
        $backupfolder = $backupfolder + 'Produktion\' + $ComputerName
      }
      catch {
        Write-Error -Message $_.Exception.Message
      }
    }
    'Acc' {
      Write-Verbose 'Acc'
      try {
        Add-ADGroupMember -Identity 'sec-sql-backup-acc-rw' -Members $ComputerName'$'
        $backupfolder = $backupfolder + 'Acceptans\' + $ComputerName
      }
      catch {
        Write-Error -Message $_.Exception.Message
      }
    }
    'Test' {
      Write-Verbose 'Test'
      try {
        Add-ADGroupMember -Identity 'sec-sql-backup-test-rw' -Members $ComputerName'$'
        $backupfolder = $backupfolder + 'Test\' + $ComputerName
      }
      catch {
        Write-Error -Message $_.Exception.Message
      }
    }
  }
    
  # I dont handle if I get an error in adding the computerobject to the group  
  Write-Output -InputObject $backupfolder #Returns the created backupfolder to the main script
} # Function Get-SQLBackupfolder done


function Add-SQLGroup {
  [CmdletBinding()]
  param(
    # Computername
    [Parameter(Mandatory,
      ValueFromPipelineByPropertyName,
      Position = 0)]
    [String]$ComputerName,

    # Typ of installation: Default (default), AO (Always On), Latin, SSRS (reporting), SSASM (Multidimension), SSAST (Tabular), SSIS, SP (Sharepoint), SCOM
    [Parameter(Mandatory, ValueFromPipelineByPropertyName,
      Position = 1)]
    [String]$sql
		
  )
  Begin {
    # Adding the server to AD Groups for rights and GPO:s
    $SQLAnalysis = 'Cmp-Sod-SQL-Analysis'
    $SQLDatabase = 'Cmp-Sod-SQL-Database'
    $SQLReporting = 'Cmp-Sod-SQL-Reporting'
    $SQLAlwaysOn = 'Cmp-Sod-SQL-AlwaysOn'
    $SQLSSIS = 'Cmp-Sod-SQL-SSIS'
  }	

  process {       
    switch ($sql) {
      'AO' {
        Add-ADGroupMember -Identity $SQLAlwaysOn -Members $ComputerName'$'
      }
      'SSRS' {
        Add-ADGroupMember -Identity $SQLReporting -Members $ComputerName'$'
        Add-ADGroupMember -Identity $SQLDatabase -Members $ComputerName'$'
      }
      'SSIS' {
        Add-ADGroupMember -Identity $SQLSSIS -Members $ComputerName'$'
        Add-ADGroupMember -Identity $SQLDatabase -Members $ComputerName'$'
      }
      'SSAST' {
        Add-ADGroupMember -Identity $SQLAnalysis -Members $ComputerName'$'
      }
      'SSASM' {
        Add-ADGroupMember -Identity $SQLAnalysis -Members $ComputerName'$'
      }
      'SCOM' {
        Add-ADGroupMember -Identity $SQLReporting -Members $ComputerName'$'
        Add-ADGroupMember -Identity $SQLDatabase -Members $ComputerName'$'
      }
      'Default' {
        Add-ADGroupMember -Identity $SQLDatabase -Members $ComputerName'$'
      }
      'SP' {
        Add-ADGroupMember -Identity $SQLDatabase -Members $ComputerName'$'
      }
      'Latin' {
        Add-ADGroupMember -Identity $SQLDatabase -Members $ComputerName'$'
      }
    }
  }
} # Function Set-SQLGroups done


# Consider rewriting so that its more flexible
Function Set-SQLDisk {
  [CmdletBinding( SupportsShouldProcess)]
  Param(
    #Computername of the server
    [String]$ComputerName, 
    # Credential object of the user running the script
		
    [ValidateScript( {
        if ($_ -is [System.Management.Automation.PSCredential]) {
          $True
        }
        elseif ($_ -is [string]) {
          $Script:Credential = Get-Credential -Credential $_
          $True
        }
        else {
          Throw "You passed an unexpected object type for the credential."
        }
      })]
    [object]$userobj #  (Is this the right way)?
  )

  # Have them hardcoded.
  $T = 'T' # Tempdb Disk
  $H = 'H' # Log disk
  $G = 'G' # Data disk
  $cim = New-CimSession $ComputerName -Credential $userobj
  Write-Verbose -Message 'Checking for offline disks'
  if (Get-Disk -CimSession $cim | Where-Object -Property isoffline) {
    try {
      Write-verbose -Message 'Setting up disk'
      Get-Disk -CimSession $cim | Where-Object -Property isoffline | Set-Disk -CimSession $cim -IsOffline:$false 
      Get-Disk -CimSession $cim | Where-Object -Property IsReadOnly | Set-Disk -CimSession $cim -IsReadOnly:$false
      Get-Disk -CimSession $cim |	Where-Object -Property partitionstyle -EQ -Value 'raw' |		Initialize-Disk -CimSession $cim -PartitionStyle GPT -PassThru |
        New-Partition -CimSession $cim -UseMaximumSize |	
        Format-Volume -CimSession $cim -FileSystem NTFS -AllocationUnitSize 65536 -Confirm:$false

      Set-Partition -CimSession $cim -DiskNumber 1 -PartitionNumber 2 -newDriveLetter $G | Set-Volume -DriveLetter $G -NewFileSystemLabel 'SQLData'
      Set-Partition -CimSession $cim -DiskNumber 2 -PartitionNumber 2 -newDriveLetter $H | Set-Volume -DriveLetter $H -NewFileSystemLabel 'SQLLog'
      Set-Partition -CimSession $cim -DiskNumber 3 -PartitionNumber 2 -NewDriveLetter $T | Set-Volume -DriveLetter $T -NewFileSystemLabel 'SQLTempDB'
      Write-Output -InputObject 'Discs created'
    }
    catch {
      Write-Error  -Message $_.Exception.Message
    }
  }
  Remove-CimSession $cim
} # Function Set-SQLDisk done

Function Wait-SQLService {
  [CmdletBinding()]
  param(
    $ComputerName
  )
  $started = $null
  do {
    Start-Sleep -Seconds 5
    $started = (Get-Service -Name MSSQLSERVER -ComputerName $ComputerName).Status
    Write-Verbose -Message 'Waiting for MSSQLSERVER'
  }
  until ($started -eq 'Running') # Waits until the service is started and then 
} #Function wait-SQLService Done

Function Test-SQL {
  [CmdletBinding()]
  [OutputType([bool])]
  param(
    [Parameter(Mandatory, HelpMessage = 'Name for the SQL Server',
      ValueFromPipelineByPropertyName,
      Position = 0)]
    [ValidateScript( {
        if (-not (Test-Connection -ComputerName $_ -Quiet -Count 1)) {
          throw "The computer $_ could not be reached."
        }
        else {
          Write-Output -InputObject $true
        }
      })]
    [ValidateLength(1, 15)]
    [string]$ComputerName
  )
  $sqlservices = 'MSSQLSERVER,MSSQLServerOLAPService,MsDtsServer,MsDtsServer110,MsDtsServer120,MsDtsServer130,MsDtsServer140,ReportServer'
  if (Get-Service -Name $sqlservices -ComputerName $ComputerName -ErrorAction SilentlyContinue) {
    $true # Services Exists
  }
  else {
    $false # Services doesn't exists
  }
} # Function Test-SQL done

function Install-SQL {
  <#
			.Synopsis
			Installation av SQL
			.DESCRIPTION
			Installation of SQL Server, the choise of enviroment and type of installation is made by parameters
			Standard installation is SQL server 2016 standard edition with swedish_finnish collation to a test enviroment
			.EXAMPLE
			Standard installation is SQL server with swedish_finnish collation to a test enviroment
			install-sql ServerName
			.EXAMPLE
			To install a SSQL Server 2014 enterprise server in a testenvirment with swedish_finish collation
			install-sql -Server ServerName -Env Test -Type Default -Ver 2014

	#>
  [CmdletBinding()]
  [OutputType([string])]
  Param
  (
    # Name for the SQL Server
    [Parameter(Mandatory, HelpMessage = 'Name for the SQL Server',
      ValueFromPipelineByPropertyName,
      Position = 0)]
    [ValidateScript( {
        if (-not (Test-Connection -ComputerName $_ -Quiet -Count 1)) {
          throw "The computer $_ could not be reached."
        }
        else {
          Write-Output -InputObject $true
        }
      })]
    [ValidateLength(1, 15)]
    [String]$server,

    # Environment variable, Prod, Acc eller Test (Alter as needed)
    [Parameter(ValueFromPipelineByPropertyName,
      Position = 1)]
    [ValidateSet('Prod', 'Acc', 'Test')]
    [String]$env = 'Test',

    # Type of installation: Default (default), AO (Always On), Latin, SSRS (reporting), SSASM (Multidimension), SSAST (Tabular), SSIS, SP (Sharepoint), SCOM
    # Each instllation type has its own ini file. 
    [Parameter(ValueFromPipelineByPropertyName,
      Position = 2)]
    [ValidateSet('Default', 'AO', 'Latin', 'SSRS', 'SSASM', 'SSIS', 'SSAST', 'SP', 'SCOM')]
    [String]$sql = 'Default',

    # SQL Server Version (Alter as needed)
    [Parameter(ValueFromPipelineByPropertyName,
      Position = 3)]
    [ValidateSet('2008', '2012', '2014', '2016')]
    [String]$version = '2016',

    # SQL Server type (Ent (Enterprise), Std (Standard)) 
    [Parameter(ValueFromPipelineByPropertyName,
      Position = 4)]
    [ValidateSet('Std', 'Ent')]
    [String]$Edition = 'Std'
  )

  Begin {
    if (Test-SQL -ComputerName $server) {
      Throw "$server has running SQL services"
    }
        
    # Defaults needs to change for the enviroment you are in.
    $domain = 'domain.local'
    $backupfolder = "\\$domain\backupfolder"
    $rootInstallfolder = "\\$domain\Installfolder"
    $setupfolder = "$rootInstallfolder\$version\$edition"

    # Startpath of the script.
    $startpath = (Get-Location).path
		
    Test-WSManCredSSP
    Import-Module -Name SQLServer -DisableNameChecking
  }

  Process {
    [System.Management.Automation.CredentialAttribute()]$credential = Get-Credential -UserName $env:USERDOMAIN\$env:username -Message 'Konto för installation av SQL server'

    # Creating the backup folder structure
    Write-Verbose -Message 'Setting Backupfolder'
    $backupfolder = Get-SQLBackupFolder -ComputerName $server -env $env -backupfolder $backupfolder
 
    # Adding the server to AD groups for rights and GPO:s
    Write-Verbose -Message 'Adding to AD groups for SQL Server'
    Add-SQLGroup -ComputerName $server -sql $sql
			
    # Making sure the server gets the gpo:s it should (Mayby it needs a reboot)
    Write-Verbose -Message 'GPO Update'
    Invoke-GPUpdate -Computer $server -Force

    # Checking windows features that needs to be installed or uninstalled
    Write-Verbose -Message 'Kontrollera att NET-Framework-Core är installerat'
    Test-WindowsFeature -ComputerName $server -Name 'NET-Framework-Core' -Action Install
    Test-WindowsFeature -ComputerName $server -Name 'FS-SMB1' -Action Uninstall
			
    if ($sql -eq 'AO') {
      Test-WindowsFeature -ComputerName $server -Name 'failover-clustering' -Action Install
    }

    # Restart the computer and wait for powershell to be started
    Restart-Computer -ComputerName ('{0}.{1}' -f $server, $domain) -Wait -For powershell -Force

    # Enable credssp on the server so that we can use credssp authentication
    Write-Verbose -Message 'Invoke-Command to enable WSManCredSSP'
    Invoke-Command -ComputerName ('{0}.{1}' -f $server, $domain) -Credential $credential -ScriptBlock {
      Enable-WSManCredSSP -Role Server -Force
    }

    # Sätter upp diskarna enligt den standard som sql servrar skall ha
    Write-Verbose -Message 'Calling Set-SQLDisk to set up the disks'
    try {
      Set-SQLDisk -ComputerName $server -userobj $credential
    }
    Catch {
      Write-Error -Message $_.Exception.Message
    }
			
    # Installerar SQL
        
    switch ($sql) {
      'Default' {
        $configFileName = 'ConfigurationFile.ini'
      }
      'AO' {
        $configFileName = 'ConfigurationFile.ini'
      }
      'Latin' {
        $configFileName = 'ConfigurationFileLatin.ini'
      }
      'SSRS' {
        $configFileName = 'ConfigurationFileRS.ini'
      }
      'SSASM' {
        $configFileName = 'ConfigurationFileSSASM.ini'
      }
      'SSIS' {
        $configFileName = 'ConfigurationFileSSIS.ini'
      }
      'SSAST' {
        $configFileName = 'ConfigurationFileSSAST.ini'
      }
      'SP' {
        $configFileName = 'ConfigurationFileSharepoint.ini'
      }
      'SCOM' {
        $configFileName = 'ConfigurationFileSCOM.ini'
      }
    }
		
    Write-Verbose -Message 'Set up the session to the computer with credssp'
    # Session paramenters
    $sessParams = @{
      ComputerName   = ('{0}.{1}' -f $server, $domain)
      Credential     = $credential
      Authentication = 'CredSSP'
    } 
    # Create the new session
    $session = New-PSSession @sessParams

    # Invoke-Command parameters
    $icmParams = @{
      Session = $session
    }
        
    Write-Verbose -message 'Invoke-command to setup the disk to installation media'
    # Invoke-Command setting up the new psdrive on the server
    Invoke-Command @icmParams -ScriptBlock {
      New-PSDrive -Name z -PSProvider FileSystem -Root "$($args[0])"
      Set-Location -Path z:
    } -ArgumentList ($setupfolder) #Root folder , version of Sql (2016) and edition

		
    #Invoke-Command @icmParams -ScriptBlock {
    #	Set-Location -Path $args[0]
    #} -ArgumentList $env
    Write-Verbose -message 'Invoke-command to install SQL server'
    Invoke-Command @icmParams -ScriptBlock {
      .\setup.exe "/CONFIGURATIONFILE=$($args[0])"
      Set-Location -Path c:
      Remove-PSDrive -Name z
    } -ArgumentList $configFileName

    Remove-PSSession -Session $session
    #Installation of SQL server Done

    # Configuration of the SQL servern

    switch ($sql) {
      {
        ($_ -eq 'Default') -or 
        ($_ -eq 'SSRS') -or 
        ($_ -eq 'AO') -or 
        ($_ -eq 'Latin') -or 
        ($_ -eq 'SSIS') -or 
        ($_ -eq 'SP') -or 
        ($_ -eq 'SCOM')
      } {
        # Waits for the SQL server to start up
        Wait-SQLService -ComputerName $server
                
        #					try 
        #					{
        #						# Skapa anslutningen till sql servern
        #						$sqlserver = New-Object -TypeName ('Microsoft.SqlServer.Management.Smo.Server') -ArgumentList $server
        #			       
        #						# Traceflaggor som skall finnas på samtliga servrar
        #						if ($version -ne '2016') 
        #						{
        #							Invoke-Sqlcmd -InputFile '$rootInstallfolder\SQL\enable traceflags startup.sql' -ServerInstance $server # Lägger in så att vissa traceflaggor alltid startas
        #						}
        #			               
        #						# När frågor får gå parallellt   
        #						$sqlserver.Configuration.CostThresholdForParallelism.ConfigValue = 50
        #			               
        #						# Hur mycket minne server skall ha. Minst 2GB till Windows Server.
        #						$memory = (Invoke-Sqlcmd -ServerInstance $server -Query 'Select physical_memory_kb/1024-2048 AS [MB] FROM sys.dm_os_sys_info WITH (NOLOCK) OPTION (RECOMPILE);').mb
        #						if ($memory -ge 2047)  
        #						{
        #							$sqlserver.Configuration.MaxServerMemory.ConfigValue = $memory
        #						}
        #
        #						# Backup folder
        #						$sqlserver.BackupDirectory = $backupfolder
        #						$sqlserver.Configuration.alter()
        #					}
        #					catch 
        #					{
        #						Write-Output -InputObject 'Gick inte att sätta server configuration på sql server.'
        #					}
        #				
        #					# Uppsättning av MgmtDB databas och maintinance skript   
        #					Invoke-Sqlcmd -InputFile $rootInstallfolder\SQL\drift.sql -ServerInstance $server  # skapar Drift
        #					Invoke-Sqlcmd -InputFile '$rootInstallfolder\SQL\who is active.sql' -ServerInstance $server -Database $Drift # Who is active
        #			       
        #					Invoke-Sqlcmd -InputFile $rootInstallfolder\SQL\sp_Blitz.sql -ServerInstance $server -Database $Drift # the parameter -database can be omitted based on what your sql script does
        #					Invoke-Sqlcmd -InputFile $rootInstallfolder\SQL\sp_BlitzCache.sql -ServerInstance $server -Database $Drift # the parameter -database can be omitted based on what your sql script does
        #					Invoke-Sqlcmd -InputFile $rootInstallfolder\SQL\sp_BlitzIndex.sql -ServerInstance $server -Database $Drift # the parameter -database can be omitted based on what your sql script does
        #					Invoke-Sqlcmd -InputFile $rootInstallfolder\SQL\sp_BlitzTrace.sql -ServerInstance $server -Database $Drift # the parameter -database can be omitted based on what your sql script does
        #					Invoke-Sqlcmd -InputFile $rootInstallfolder\SQL\sp_BlitzWho.sql -ServerInstance $server -Database $Drift # the parameter -database can be omitted based on what your sql script does
        #					Invoke-Sqlcmd -InputFile $rootInstallfolder\SQL\sp_BlitzFirst.sql -ServerInstance $server -Database $Drift # the parameter -database can be omitted based on what your sql script does
        #					Invoke-Sqlcmd -InputFile $rootInstallfolder\SQL\sp_foreachdb.sql -ServerInstance $server # the parameter -database can be omitted based on what your sql script does
        #			       
        #			       
        #					switch ($env)
        #					{
        #						'Prod' 
        #						{
        #							Invoke-Sqlcmd -InputFile $rootInstallfolder\SQL\MaintenanceSolution.sql -ServerInstance $server -Database $Drift # the parameter -database can be omitted based on what your sql script does
        #							Invoke-Sqlcmd -InputFile $rootInstallfolder\SQL\Jobb.sql -ServerInstance $server -Database $Drift # the parameter -database can be omitted based on what your sql script does
        #							Invoke-Sqlcmd -InputFile $rootInstallfolder\SQL\Schema.sql -ServerInstance $server -Database $Drift # the parameter -database can be omitted based on what your sql script does      
        #						}
        #						'Acc'  
        #						{
        #							Invoke-Sqlcmd -InputFile $rootInstallfolder\SQL\MaintenanceSolution-Acc.sql -ServerInstance $server -Database $Drift # the parameter -database can be omitted based on what your sql script does
        #							Invoke-Sqlcmd -InputFile $rootInstallfolder\SQL\Jobb-Acc.sql -ServerInstance $server -Database $Drift # the parameter -database can be omitted based on what your sql script does
        #							Invoke-Sqlcmd -InputFile $rootInstallfolder\SQL\Schema-Acc.sql -ServerInstance $server -Database $Drift # the parameter -database can be omitted based on what your sql script does 
        #						}
        #						'Test' 
        #						{
        #							Invoke-Sqlcmd -InputFile $rootInstallfolder\SQL\MaintenanceSolution-Test.sql -ServerInstance $server -Database $Drift # the parameter -database can be omitted based on what your sql script does
        #							Invoke-Sqlcmd -InputFile $rootInstallfolder\SQL\Jobb-Test.sql -ServerInstance $server -Database $Drift # the parameter -database can be omitted based on what your sql script does
        #							Invoke-Sqlcmd -InputFile $rootInstallfolder\SQL\Schema-Test.sql -ServerInstance $server -Database $Drift # the parameter -database can be omitted based on what your sql script does 
        #						}
        #					}
      }

    }
    #		}
  }
    
  End {
    #		if ($check -eq 'N') 
    #		{
    #			Write-Host -Object 'Installationen avbröts' -ForegroundColor Red
    #			Throw 'Installation unseccesfull'
    #		}
    #		else
    #		{
    # Auto installationen klar
    Write-Output 'Install Done'
    #Write-Host -Object 'Installationen klar. Kvarstår att göra de manuella inställningarna' -ForegroundColor DarkGreen
    #		}
    Set-Location -Path $startpath
  }
}
