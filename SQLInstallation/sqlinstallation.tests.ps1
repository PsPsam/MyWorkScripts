﻿# this is a Pester test file

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


#Describe 'Testing against PSSA rules' {
#	Context 'PSSA Standard Rules' {
#		$analysis = Invoke-ScriptAnalyzer -Path '.\sqlinstallation.ps1' -ExcludeRule PSAvoidUsingWriteHost
#		$scriptAnalyzerRules = Get-ScriptAnalyzerRule
#		forEach ($rule in $scriptAnalyzerRules) {
#			It "Should pass $rule" {
#				If ($analysis.RuleName -contains $rule) {
#					$analysis |
#					Where-Object -Property RuleName -EQ -Value $rule -OutVariable failures |
#					Out-Default
#					$failures.Count | Should Be 0
#				}
#			}
#		}
#	}
#}

# describes the function Test-WSManCredSSP
Describe -Name 'Test-WSManCredSSP' -Fixture {
	Context -Name 'Input' -Fixture {

	}
	Context -Name 'Execution' -Fixture {

	}
	Context -Name 'Output' -Fixture {

	}
}

# Test if feature is or is not installed and take action 
Describe -Name 'Test-WindowsFeature' -Fixture {
	$actionCase = @(
		@{
			action  = 'Install'
			TestCase = 'Install'
		}
		@{
			action  = 'Uninstall'
			TestCase = 'Uninstall'
		}
	)
	Context -Name 'Input' -Fixture {
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

	Context -Name 'Execution' -Fixture {
		It -name 'When feature is installed and you want to install it' -test {
			Mock -CommandName 'install-windowsfeature' -MockWith {

			}
		}
	}
	Context -Name 'Output' -Fixture {

	}
}

Describe -Name 'Get-SQLBackupFolder' -Fixture {
	Context -Name 'Input' -Fixture {

	}
	Context -Name 'Execution' -Fixture {

	}
	Context -Name 'Output' -Fixture {

	}
}

Describe -Name 'Test-WSManCredSSP' -Fixture {
	Context -Name 'Input' -Fixture {

	}
	Context -Name 'Execution' -Fixture {

	}
	Context -Name 'Output' -Fixture {

	}
}

Describe -Name 'Set-SQLGroup' -Fixture {
	Context -Name 'Input' -Fixture {

	}
	Context -Name 'Execution' -Fixture {

	}
	Context -Name 'Output' -Fixture {

	}
}

Describe -Name 'Set-SQLDisks' -Fixture {
	Context -Name 'Input' -Fixture {

	}
	Context -Name 'Execution' -Fixture {

	}
	Context -Name 'Output' -Fixture {

	}
}

Describe -Name 'Test-SQL' -Fixture {
	Context -Name 'Input' -Fixture {

	}
	Context -Name 'Execution' -Fixture {

	}
	Context -Name 'Output' -Fixture {

	}
}

Describe -Name 'Wait-SQLService' -Fixture {
	Context -Name 'Input' -Fixture {

	}
	Context -Name 'Execution' -Fixture {

	}
	Context -Name 'Output' -Fixture {

	}
}

Describe -Name 'Install-SQL' -Fixture {
	$envCase = @(
		@{
			env   = 'Test'
			TestName = 'Test'
		}
		@{
			env   = 'Acc'
			TestName = 'Acc'
		}
		@{
			env   = 'Prod'
			TestName = 'Prod'
		}
	)
	$SqlCase = @(
		@{
			Sql   = 'Sodra'
			TestName = 'Sodra'
		}
		@{
			Sql   = 'AO'
			TestName = 'AO'
		}
		@{
			Sql   = 'Latin'
			TestName = 'Latin'
		}
		@{
			Sql   = 'SSRS'
			TestName = 'SSRS'
		}
		@{
			Sql   = 'SSASM'
			TestName = 'SSASM'
		}
		@{
			Sql   = 'SSIS'
			TestName = 'SSIS'
		}
		@{
			Sql   = 'SSAST'
			TestName = 'SSAST'
		}
		@{
			Sql   = 'SP'
			TestName = 'SP'
		}
		@{
			Sql   = 'SCOM'
			TestName = 'SCOM'
		}
	)
	$VersionCase = @(
		@{
			Version = '2008'
			TestName = '2008'
		}
		@{
			Version = '2012'
			TestName = '2012'
		}
		@{
			Version = '2014'
			TestName = '2014'
		}
		@{
			Version = '2016'
			TestName = '2016'
		}
	)
	$typeCase = @(
		@{
			Type   = 'Ent'
			TestName = 'Ent'
		}
		@{
			Type   = 'Std'
			TestName = 'Std'
		}
	)

	Context -Name 'Input' -Fixture {
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

		$parameterInfo = (Get-Command Install-SQL).Parameters['type']
		It -name 'Has ValidateSet for parameter Install-SQL for input type' -test {
			$parameterInfo.Attributes.Where{$_ -is [ValidateSet]}.Count | Should be 1
		}
		
		It -name 'ValidateSet contains option <TestName>' -TestCases $typeCase -test {
			param($type)
			(Get-Command Install-SQL).Parameters['Type'].Attributes.ValidValues -contains $type | Should be $true
		}

		$parameterInfo = (Get-Command Install-SQL).Parameters['env']
		It -name 'Has ValidateSet for parameter Install-SQL for input enviroment' -test {
			$parameterInfo.Attributes.Where{$_ -is [ValidateSet]}.Count | Should be 1
		}
		
		It -name 'ValidateSet contains option <TestName>' -TestCases $envCase -test {
			param($env)
			(Get-Command Install-SQL).Parameters['env'].Attributes.ValidValues -contains $env | Should be $true
		}
		
		It -name 'When server is offline, it will throw an exception'	 -test {
			Mock -CommandName 'Test-Connection' -MockWith {$false}
			{Install-SQL -server 'IAMOFFLINE'} | Should throw 'could not be reached'
		}

	}
	Context -Name 'Execution' -Fixture {
		mock 'Test-Connection' {$true} 
		mock 'Test-SQL' {$false}
		Mock Test-WSManCredSSP {$true}
		Mock Get-SQLBackupFolder {} #
		it 'When installing SQL get SQL backupfolder' {
			$null = install-sql -server 'IAMONLINE'
			$assMParams = @{
				CommandName = 'Get-SQLBackupFolder'
				Times = 1
				Scope = 'It'
				Exactly = $true
			}
			Assert-MockCalled @assMParams	
		}
	}
	
	Context -Name 'Output' -Fixture {
		
		It 'Server allready have SQL Installed' {
			mock 'Test-Connection' {$true}
			mock 'Test-SQL' {$true}

			{Install-Sql -server 'IAMONLINE'} | Should Throw 'IAMONLINE has running SQL services'
		}	
	}
}