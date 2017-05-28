# this is a Pester test file

#region Further Reading
# http://www.powershellmagazine.com/2014/03/27/testing-your-powershell-scripts-with-pester-assertions-and-more/
#endregion
#region LoadScript
# load the script file into memory
# attention: make sure the script only contains function definitions
# and no active code. The entire script will be executed to load
# all functions into memory
#. ($PSCommandPath -replace '\.tests\.ps1$', '.ps1')
#endregion

. .\SQLInstall.ps1

Describe "Check with Scriptanalyser" {
  It 'must pass PSScriptAnalyzer rules' {
    Invoke-ScriptAnalyzer -Path ".\Remove-backupfile.ps1" | should beNullOrEmpty
  }
}

# describes the function Test-WSManCredSSP
Describe -Name 'Test-WSManCredSSP' -Tag 'Test-WSManCredSSP' {
  Context -Name 'Input' {
        
  }
  Context -Name 'Execution' {
  }
  Context -Name 'Output' {
    it -Name 'WSMANCredSSP is enabled should outupt $true' -test {
      mock get-item {$true}
      Test-WSManCredSSP | Should be $true
    }
    it -name 'Should return System.Xml.XmlElement if it enables wsmancredssp' {
      mock get-item {$false}
      mock Enable-WSManCredSSP {New-MockObject System.Xml.XmlElement}
      Test-WSManCredSSP | Should be 'System.Xml.XmlElement'
    }
        
    it -name 'failes to enable WSManCredSSP role client' -test {
      mock get-item {$false}
      mock Enable-WSManCredSSP { Throw }
      Test-WSManCredSSP | Should be 'Enable-WSManCredSSP unsuccessfull'
    }
  }
}

# Test if feature is or is not installed and take action 
Describe -Name 'Test-WindowsFeature' -Tag 'Test-WindowsFeature' {
  $actionCase = @(
    @{
      action   = 'Install'
      TestCase = 'Install'
    }
    @{
      action   = 'Uninstall'
      TestCase = 'Uninstall'
    }
  )
  Context -Name 'Input' {
    $parameterInfo = (Get-Command Test-WindowsFeature).Parameters['ComputerName']
    It -name 'Parameter ComputerName Should be of type String' -test {
      $parameterInfo.ParameterType.Name | Should Be 'String'
    }
    
    $parameterInfo = (Get-Command Test-WindowsFeature).Parameters['Name']

    It -name 'Parameter Name Should be of type String' -test {
      $parameterInfo.ParameterType.Name | Should Be 'String'
    }

    $parameterInfo = (Get-Command Test-WindowsFeature).Parameters['action']
    It -name 'Has ValidateSet for parameter Install-SQL for input Sql installationstyp' -test {
      $parameterInfo.Attributes.Where{
        $_ -is [ValidateSet]
      }.Count | Should be 1
    }
    It -name 'Should be of type String' -test {
      $parameterInfo.ParameterType.Name | Should Be 'String'
    }
    It -name 'ValidateSet contains option <TestCase>' -TestCases $actionCase -test {
      param($action)
      $parameterInfo.Attributes.ValidValues -contains $action | Should be $true
    }
  }
  Context -Name 'Execution' {

  }
  Context -Name 'Output' {
    # Test when installing Windows feature       
    It -name 'When installing a feature and its installed: ' -test {
      Mock Get-WindowsFeature { 
        [PSCustomObject]@{Installed = $true} 
      }
      Test-windowsfeature -ComputerName 'SERVER' -Name 'FEATURENAME' -Action 'INSTALL' | Should be 'SERVER has feature FEATURENAME Installed'
    }

    It -name 'When installing a feature and SXS folder does not exist: ' -test {
      mock 
    }
    It -name 'When installing a feature and installed and succesfully: ' -test {
      Mock Get-WindowsFeature { 
        [PSCustomObject]@{Installed = $false} 
      }
      Mock Install-WindowsFeature {
        [PSCustomObject]@{Exitcode = 'Success'} 
      }

      Test-windowsfeature -ComputerName 'SERVER' -Name 'FEATURENAME' -Action 'INSTALL' | Should be 'SERVER got feature FEATURENAME Installed'
    }

    It -name 'When installing a feature and installation failes: ' -test {
      Mock Get-WindowsFeature { 
        [PSCustomObject]@{Installed = $false} 
      }
      Mock Install-WindowsFeature {
        [PSCustomObject]@{Installed = $false} 
      }
      Test-windowsfeature -ComputerName 'SERVER' -Name 'FEATURENAME' -Action 'INSTALL' | Should be ' SERVER has feature FEATURENAME Installed'
    }

    # Test when uninstalling windows feature
    It -name 'When uninstalling a feature and its removed: ' -test {
      Mock Get-WindowsFeature { 
        [PSCustomObject]@{Installed = $true} 
      }
      Test-windowsfeature -ComputerName 'SERVER' -Name 'FEATURENAME' -Action 'INSTALL' | Should be 'SERVER got feature FEATURENAME removed'
    }

    It -name 'When uninstalling a feature and it failes' -test {
      Mock Get-WindowsFeature { 
        [PSCustomObject]@{Installed = $true} 
      }
      Test-windowsfeature -ComputerName 'SERVER' -Name 'FEATURENAME' -Action 'INSTALL' | Should be 'SERVER failed to remove feature FEATURENAME'
    }

    It -name 'When uninstalling a feature and its not installed' -test {
      Mock Get-WindowsFeature { 
        [PSCustomObject]@{Installed = $true} 
      }
      Test-windowsfeature -ComputerName 'SERVER' -Name 'FEATURENAME' -Action 'INSTALL' | Should be 'SERVER does not have feature FEATURENAME Installed'
    }
  }
}

Describe -Name 'Get-SQLBackupFolder' -Tag 'Get-SQLBackupFolder' {
  #Should use testcase
  Context -Name 'Input' {
    It -name 'Only allow a singel computer' {}
    It -name 'Only allow the strings "Prod","Acc" and "Test" to be used for env' {}
    It -name 'Should be a string with the base backupfolder' {}
  }
  Context -Name 'Execution' -Fixture {
    It -name 'Should add account to group Get-SQLBackupFolder' {}
  }
  Context -Name 'Output' {
    it -name 'Should output the sql backupfolder for the server to use' {}
  }
}

Describe -Name 'Add-SQLGroup' -Tag 'Add-SQLGroup' {
  # Testcase
  Context -Name 'Input' {
    It -name 'Parameter ComputerName: Only allow a singel computer' {}
    It -name 'Only allow the strings "Prod","Acc" and "Test" to be used for env' {}
  }
  Context -Name 'Execution' {
    It -name 'Should add account to group Set-SQLGrop:' {}
  }
  Context -Name 'Output' {
  }
}

Describe -Name 'Set-SQLDisks' -Tag 'Set-SQLDisks' {
  Context -Name 'Input' {
    It -name 'Parameter ComputerName: Only allow a singel computer' {}
    It -name 'Parameter UserObj: Should Throw if not credential object' {}
    It -name 'Parameter UserObj: Only allow credential object' {}
  }
  Context -Name 'Execution' {
    It -name 'Should create a cim session to the computer'
    It -name 'Should get disk through the cimsession that is online: Ends' {}
    # How to test a long chain of piping 
    # On done on the cim session
    It 'Should get disk that is offline and set them online' {}
    It 'Should get disk that is readonly and set them readwrite' {}
    It 'Should get disk that is raw and create partition and format the disk' {}
    It 'Should set partition on disk 1' {}
    It 'Should set partition on disk 2' {}
    It 'Should set partition on disk 3' {}
    It 'Should throw if any error setting up disk on computer:' {}
    It 'Should remove cim session' {}
  }
  Context -Name 'Output' {

  }
}

Describe -Name 'Wait-SQLService' -Tag 'Wait-SQLService' {
  Context -Name 'Input' {
    It -name 'Parameter ComputerName: Only allow a singel computer' {}
  }
  Context -Name 'Execution' {
    It 'Should sleep for 5 seconds' {}
    It 'Should get status of sqlservice' {}
  }
  Context -Name 'Output' {

  }
}

Describe -Name 'Test-SQL' -Tag 'Test-SQL' {
  Context -Name 'Input' {

    $parameterInfo = (Get-Command Test-SQL).Parameters['Computername']
    It -name 'Has ValidateSet for parameter Install-SQL for input Sql installationstyp' -test {
      $parameterInfo.Attributes.Where{$_ -is [ValidateSet]}.Count | Should be 1
    }
  }

  Context -Name 'Execution' -Fixture {
    It 'Should execute get-service' {}
  }
  Context -Name 'Output' {

    It 'Should return true if any sql services exists' {}
    It 'Should return false if no sql services is installed' {}
  }
}

Describe -Name 'Install-SQL' -Tag 'Install-SQL' {
  $envCase = @(
    @{
      env      = 'Test'
      TestName = 'Test'
    }
    @{
      env      = 'Acc'
      TestName = 'Acc'
    }
    @{
      env      = 'Prod'
      TestName = 'Prod'
    }
  )
  $SqlCase = @(
    @{
      Sql      = 'Default'
      TestName = 'Default'
    }
    @{
      Sql      = 'AO'
      TestName = 'AO'
    }
    @{
      Sql      = 'Latin'
      TestName = 'Latin'
    }
    @{
      Sql      = 'SSRS'
      TestName = 'SSRS'
    }
    @{
      Sql      = 'SSASM'
      TestName = 'SSASM'
    }
    @{
      Sql      = 'SSIS'
      TestName = 'SSIS'
    }
    @{
      Sql      = 'SSAST'
      TestName = 'SSAST'
    }
    @{
      Sql      = 'SP'
      TestName = 'SP'
    }
    @{
      Sql      = 'SCOM'
      TestName = 'SCOM'
    }
  )
  $VersionCase = @(
    @{
      Version  = '2008'
      TestName = '2008'
    }
    @{
      Version  = '2012'
      TestName = '2012'
    }
    @{
      Version  = '2014'
      TestName = '2014'
    }
    @{
      Version  = '2016'
      TestName = '2016'
    }
  )
  $EditionCase = @(
    @{
      Edition  = 'Ent'
      TestName = 'Ent'
    }
    @{
      Edition  = 'Std'
      TestName = 'Std'
    }
  )

  Context -Name 'Input' {
    #Parameter testing
    $parameterInfo = (Get-Command Install-SQL).Parameters['sql']
    It -name 'Has ValidateSet for parameter Install-SQL for input Sql installationstyp' -test {
      $parameterInfo.Attributes.Where{$_ -is [ValidateSet]}.Count | Should be 1
    }
		
    It -name 'ValidateSet contains option <TestName>' -TestCases $SqlCase -test {
      param($sql)
      $parameterInfo.Attributes.ValidValues -contains $sql | Should be $true
    }
		
    $parameterInfo = (Get-Command Install-SQL).Parameters['version']
    It -name 'Has ValidateSet for parameter Install-SQL for input Version' -test {
      $parameterInfo.Attributes.Where{$_ -is [ValidateSet]}.Count | Should be 1
    }
		
    It -name 'ValidateSet contains option <TestName>' -TestCases $VersionCase -test {
      param($version)
      (Get-Command Install-SQL).Parameters['Version'].Attributes.ValidValues -contains $version | Should be $true
    }

    $parameterInfo = (Get-Command Install-SQL).Parameters['Edition']
    It -name 'Has ValidateSet for parameter Install-SQL for input Edition' -test {
      $parameterInfo.Attributes.Where{$_ -is [ValidateSet]}.Count | Should be 1
    }
		
    It -name 'ValidateSet contains option <TestName>' -TestCases $EditionCase -test {
      param($Edition)
      (Get-Command Install-SQL).Parameters['Edition'].Attributes.ValidValues -contains $Edition | Should be $true
    }

    $parameterInfo = (Get-Command Install-SQL).Parameters['env']
    It -name 'Has ValidateSet for parameter Install-SQL for input enviroment' -test {
      $parameterInfo.Attributes.Where{$_ -is [ValidateSet]}.Count | Should be 1
    }
		
    It -name 'ValidateSet contains option <TestName>' -TestCases $envCase -test {
      param($env)
      (Get-Command Install-SQL).Parameters['env'].Attributes.ValidValues -contains $env | Should be $true
    }
		
    It -name 'When server is offline, it will throw an exception' -test {
      Mock -CommandName 'Test-Connection' -MockWith {$false}
      {Install-SQL -server 'IAMOFFLINE'} | Should throw 'could not be reached'
    }

  }
  Context -Name 'Execution' {
    mock 'Test-Connection' {$true} 
    mock 'Test-SQL' {$false}
    Mock Test-WSManCredSSP {$true}
    Mock Get-SQLBackupFolder {'\\sodra.com\sql-backup\test\IAMONLINE'} #
    Mock Add-SQLGroup {}
    Mock Invoke-Gpupdate {}
    Mock Test-WindowsFeature {} 
    Mock Restart-Computer {} # How?
    Mock Invoke-Command {}
    Mock Set-SQLDisk {}
    Mock New-PSSession {} # Should this be tested?
    Mock Invoke-Command {} #Its allready mocked should you mock it several times? Or does it use the same mock? Should the scriptblock be tested if yes how?
    Mock Remove-Pssession {}
    Mock Set-location {}
		
    it 'when server has sql service running throw' {
      mock 'Test-SQL' {$false}
      {install-sql -server 'SQLInstalled'} | Should throw 'SQLInstalled has running SQL services'
    }
    
    it 'When installing SQL get SQL backupfolder' {
      $null = Install-Sql -server 'IAMONLINE'
      $assMParams = @{
        CommandName     = 'Get-SQLBackupFolder'
        Times           = 1
        Scope           = 'It'
        Exactly         = $true
        ParameterFilter = { $ComputerName -eq 'SOMETHING' -and $env -eq 'Test' -and $backupfolder -eq '\\sodra.com\sql-backup'}
      }
      Assert-MockCalled @assMParams	
    }
    it 'When installing SQL set SQLGroup' {
      $null = Install-Sql -server 'IAMONLINE'
      $assMParams = @{
        CommandName     = 'add-SQLGroup'
        Times           = 1
        Scope           = 'It'
        Exactly         = $true
        ParameterFilter = { $ComputerName -eq 'SOMETHING' -and 'Sodra'}
      }
      Assert-MockCalled @assMParams	
    }
  }
	
  Context -Name 'Output' {
		
    It 'Server allready have SQL Installed' {
      mock 'Test-Connection' {$true}
      mock 'Test-SQL' {$true}

      {Install-Sql -server 'IAMONLINE'} | Should Throw 'IAMONLINE has running SQL services'
    }	
  }
}