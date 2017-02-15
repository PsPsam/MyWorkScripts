#requires -Version 3

Function Get-PendingReboot 
{ 
  <# 
      .SYNOPSIS 
      Gets the pending reboot status on a local or remote computer. 
 
      .DESCRIPTION 
      This function will query the registry on a local or remote computer and determine if the 
      system is pending a reboot, from either Microsoft Patching or a Software Installation. 
      For Windows 2008+ the function will query the CBS registry key as another factor in determining 
      pending reboot state.  "PendingFileRenameOperations" and "Auto Update\RebootRequired" are observed 
      as being consistant across Windows Server 2003 & 2008. 
   
      CBServicing = Component Based Servicing (Windows 2008) 
      WindowsUpdate = Windows Update / Auto Update (Windows 2003 / 2008) 
      CCMClientSDK = SCCM 2012 Clients only (DetermineIfRebootPending method) otherwise $null value 
      PendFileRename = PendingFileRenameOperations (Windows 2003 / 2008) 
 
      .PARAMETER ComputerName 
      A single Computer or an array of computer names.  The default is localhost ($env:COMPUTERNAME). 
 
      .PARAMETER ErrorLog 
      A single path to send error data to a log file. 
 
      .EXAMPLE 
      PS C:\> Get-PendingReboot -ComputerName (Get-Content C:\ServerList.txt) | Format-Table -AutoSize 
   
      Computer CBServicing WindowsUpdate CCMClientSDK PendFileRename PendFileRenVal RebootPending 
      -------- ----------- ------------- ------------ -------------- -------------- ------------- 
      DC01     False   False           False      False 
      DC02     False   False           False      False 
      FS01     False   False           False      False 
 
      This example will capture the contents of C:\ServerList.txt and query the pending reboot 
      information from the systems contained in the file and display the output in a table. The 
      null values are by design, since these systems do not have the SCCM 2012 client installed, 
      nor was the PendingFileRenameOperations value populated. 
 
      .EXAMPLE 
      PS C:\> Get-PendingReboot 
   
      Computer     : WKS01 
      CBServicing  : False 
      WindowsUpdate      : True 
      CCMClient    : False 
      PendComputerRename : False 
      PendFileRename     : False 
      PendFileRenVal     :  
      RebootPending      : True 
   
      This example will query the local machine for pending reboot information. 
   
      .EXAMPLE 
      PS C:\> $Servers = Get-Content C:\Servers.txt 
      PS C:\> Get-PendingReboot -Computer $Servers | Export-Csv C:\PendingRebootReport.csv -NoTypeInformation 
   
      This example will create a report that contains pending reboot information. 
 
      .LINK 
      Component-Based Servicing: 
      http://technet.microsoft.com/en-us/library/cc756291(v=WS.10).aspx 
   
      PendingFileRename/Auto Update: 
      http://support.microsoft.com/kb/2723674 
      http://technet.microsoft.com/en-us/library/cc960241.aspx 
      http://blogs.msdn.com/b/hansr/archive/2006/02/17/patchreboot.aspx 
 
      SCCM 2012/CCM_ClientSDK: 
      http://msdn.microsoft.com/en-us/library/jj902723.aspx 
 
      .NOTES 
      Author:  Brian Wilhite 
      Email:   bcwilhite (at) live.com 
      Date:    29AUG2012 
      PSVer:   2.0/3.0/4.0/5.0 
      Updated: 01DEC2014 
      UpdNote: Added CCMClient property - Used with SCCM 2012 Clients only 
      Added ValueFromPipelineByPropertyName=$true to the ComputerName Parameter 
      Removed $Data variable from the PSObject - it is not needed 
      Bug with the way CCMClientSDK returned null value if it was false 
      Removed unneeded variables 
      Added PendFileRenVal - Contents of the PendingFileRenameOperations Reg Entry 
      Removed .Net Registry connection, replaced with WMI StdRegProv 
      Added ComputerPendingRename 
  #> 
 
  [CmdletBinding()] 
  param( 
    [Parameter(Position = 0,ValueFromPipeline = $true,ValueFromPipelineByPropertyName = $true)] 
    [Alias('CN','Computer')] 
    [String[]]$ComputerName = "$env:COMPUTERNAME", 
    [String]$ErrorLog 
  ) 
 
  Begin {  }## End Begin Script Block 
  Process { 
    Foreach ($Computer in $ComputerName) 
    { 
      Try 
      { 
        ## Setting pending values to false to cut down on the number of else statements 
        $CompPendRen, $PendFileRename, $Pending, $SCCM = $false, $false, $false, $false 
       
        ## Setting CBSRebootPend to null since not all versions of Windows has this value 
        $CBSRebootPend = $null 
             
        ## Querying WMI for build version 
        $WMI_OS = Get-WmiObject -Class Win32_OperatingSystem -Property BuildNumber, CSName -ComputerName $Computer -ErrorAction Stop 
 
        ## Making registry connection to the local/remote computer 
        $HKLM = [UInt32] '0x80000002' 
        $WMI_Reg = [WMIClass] "\\$Computer\root\default:StdRegProv" 
             
        ## If Vista/2008 & Above query the CBS Reg Key 
        If ([Int32]$WMI_OS.BuildNumber -ge 6001) 
        { 
          $RegSubKeysCBS = $WMI_Reg.EnumKey($HKLM,'SOFTWARE\Microsoft\Windows\CurrentVersion\Component Based Servicing\') 
          $CBSRebootPend = $RegSubKeysCBS.sNames -contains 'RebootPending'     
        } 
               
        ## Query WUAU from the registry 
        $RegWUAURebootReq = $WMI_Reg.EnumKey($HKLM,'SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update\') 
        $WUAURebootReq = $RegWUAURebootReq.sNames -contains 'RebootRequired' 
             
        ## Query PendingFileRenameOperations from the registry 
        $RegSubKeySM = $WMI_Reg.GetMultiStringValue($HKLM,'SYSTEM\CurrentControlSet\Control\Session Manager\','PendingFileRenameOperations') 
        $RegValuePFRO = $RegSubKeySM.sValue 
 
        ## Query ComputerName and ActiveComputerName from the registry 
        $ActCompNm = $WMI_Reg.GetStringValue($HKLM,'SYSTEM\CurrentControlSet\Control\ComputerName\ActiveComputerName\','ComputerName')       
        $CompNm = $WMI_Reg.GetStringValue($HKLM,'SYSTEM\CurrentControlSet\Control\ComputerName\ComputerName\','ComputerName') 
        If ($ActCompNm -ne $CompNm) 
        {
          $CompPendRen = $true
        } 
             
        ## If PendingFileRenameOperations has a value set $RegValuePFRO variable to $true 
        If ($RegValuePFRO) 
        {
          $PendFileRename = $true
        } 
 
        ## Determine SCCM 2012 Client Reboot Pending Status 
        ## To avoid nested 'if' statements and unneeded WMI calls to determine if the CCM_ClientUtilities class exist, setting EA = 0 
        $CCMClientSDK = $null 
        $CCMSplat = @{
          NameSpace    = 'ROOT\ccm\ClientSDK'
          Class        = 'CCM_ClientUtilities'
          Name         = 'DetermineIfRebootPending'
          ComputerName = $Computer
          ErrorAction  = 'Stop'
        } 
        ## Try CCMClientSDK 
        Try 
        {
          $CCMClientSDK = Invoke-WmiMethod @CCMSplat
        }
        Catch [System.UnauthorizedAccessException] 
        { 
          $CcmStatus = Get-Service -Name CcmExec -ComputerName $Computer -ErrorAction SilentlyContinue 
          If ($CcmStatus.Status -ne 'Running') 
          { 
            Write-Warning -Message "$Computer`: Error - CcmExec service is not running." 
            $CCMClientSDK = $null 
          } 
        }
        Catch 
        {
          $CCMClientSDK = $null
        } 
 
        If ($CCMClientSDK) 
        { 
          If ($CCMClientSDK.ReturnValue -ne 0) 
          {
            Write-Warning -Message "Error: DetermineIfRebootPending returned error code $($CCMClientSDK.ReturnValue)"
          } 
          If ($CCMClientSDK.IsHardRebootPending -or $CCMClientSDK.RebootPending) 
          {
            $SCCM = $true
          } 
        } 
       
        Else 
        {
          $SCCM = $null
        } 
 
        ## Creating Custom PSObject and Select-Object Splat 
        $SelectSplat = @{
          Property = ( 
            'Computer', 
            'CBServicing', 
            'WindowsUpdate', 
            'CCMClientSDK', 
            'PendComputerRename', 
            'PendFileRename', 
            'PendFileRenVal', 
            'RebootPending' 
          )
        } 
        New-Object -TypeName PSObject -Property @{
          Computer           = $WMI_OS.CSName
          CBServicing        = $CBSRebootPend
          WindowsUpdate      = $WUAURebootReq
          CCMClientSDK       = $SCCM
          PendComputerRename = $CompPendRen
          PendFileRename     = $PendFileRename
          PendFileRenVal     = $RegValuePFRO
          RebootPending      = ($CompPendRen -or $CBSRebootPend -or $WUAURebootReq -or $SCCM -or $PendFileRename)
        } | Select-Object @SelectSplat
      }
      Catch 
      { 
        Write-Warning -Message "$Computer`: $_" 
        ## If $ErrorLog, log the file to a user specified location/path 
        If ($ErrorLog) 
        {
          Out-File -InputObject "$Computer`,$_" -FilePath $ErrorLog -Append
        }         
      }       
    }## End Foreach ($Computer in $ComputerName)       
  }## End Process 
 
  End {  }## End End 
}## End Function Get-PendingReboot



function Install-SccmMissingUpdates
{
<#
    .Synopsis
    Install missing updates with a reboot 
    .DESCRIPTION
    Install missing updates from SCCM on selected computerobject with a foreced reboot
    .EXAMPLE
    Install-SccmMissingUpdates Computername

#>
  [CmdletBinding(SupportsShouldProcess = $true)]
    
  Param
  (
    # The computername to install updates
    [Parameter(Mandatory = $true,
        ValueFromPipelineByPropertyName = $true,
        Position = 0,
        HelpMessage='Computername to update')]
    [string]$ComputerName
  )

  Begin
  {
    Add-Type -AssemblyName System.speech
    $speak = New-Object -TypeName System.Speech.Synthesis.SpeechSynthesizer
    $speak.SelectVoice('Microsoft Zira Desktop')
  }

  Process
  {
    # Check if there is a pending reboot already otherwise first reboot.
    $pendingreboot = Get-PendingReboot -ComputerName $ComputerName
    If ($pendingreboot.RebootPending -eq $true) 
    {
        Write-Verbose -Message "$ComputerName has restart pending, restarting...."
        Restart-Computer -ComputerName $ComputerName -Force -Wait -For WinRM
        do
        {
            Write-verbose -Message 'Waiting for ccmexec, sleep 30s'
            Start-Sleep -Seconds 30
            try {
                $ccmexec = (get-service -ComputerName $ComputerName -name ccmexec).status
            }
            catch {
                Write-error -Message "Unable to get-service on $computername exit script."
                Write-error -Message 'Start the script again.'
                exit
            }
            
        }while ($ccmexec -ne 'running')
    }
    
    #Trigger SCCM Update Scan and wait a little
    Write-Verbose -Message 'Trigger updatescan, sleep 60s'
    $null = Invoke-WmiMethod -Namespace root\ccm -Class sms_client -Name TriggerSchedule -ArgumentList '{00000000-0000-0000-0000-000000000113}' -ComputerName $ComputerName
    #Write-ToLog $LogFile "INFO   `tThe SCCM Update Scan has been triggered. The script is suspended for $(1*$waitingseconds) seconds to let the update scan finish."
    Start-Sleep -Seconds 60   
      
    [System.Management.ManagementObject[]] $CMMissingUpdates = @(Get-WmiObject -ComputerName $ComputerName -Query "SELECT * FROM CCM_SoftwareUpdate WHERE ComplianceState = '0'" -Namespace 'ROOT\ccm\ClientSDK')
    Write-Verbose -Message "The number of missing updates is $($CMMissingUpdates.count) on $ComputerName"
    $sccmmissing = $CMMissingUpdates.count

    If ($CMMissingUpdates.count -gt 0) 
    {
      $CMInstallMissingUpdates = (Get-WmiObject -ComputerName $ComputerName -Namespace 'root\ccm\clientsdk' -Class 'CCM_SoftwareUpdatesManager' -List).InstallUpdates($CMMissingUpdates)

      Do
      {
        Start-Sleep -Seconds 30
        #From http://stackoverflow.com/questions/13333223/write-progress-for-10-minutes-powershell
        [array]$CMInstallPendingUpdates = @(Get-WmiObject -ComputerName $ComputerName -Query 'SELECT * FROM CCM_SoftwareUpdate WHERE EvaluationState = 6 or EvaluationState = 7' -Namespace 'ROOT\ccm\ClientSDK')
        $installedupdates = $sccmmissing - $CMInstallPendingUpdates.Count
                
        Write-Progress -Activity "Updates are installing... $($CMMissingUpdates.count) updates to install" -Status "$installedupdates Updates installed" -PercentComplete ($installedupdates/$sccmmissing*100)
      } While ($CMInstallPendingUpdates.count -gt 0) #End Do loop.
      Start-Sleep -Seconds 30
    }
        
    $pendingreboot = Get-PendingReboot -ComputerName $ComputerName
    If ($pendingreboot.RebootPending -eq $true) 
    {
      Write-Verbose -Message 'Reboot pending'    
      Restart-Computer -ComputerName $ComputerName -Force -Wait -For WinRM
                  
      #Write-ToLog $LogFile "INFO   `tThe server has a pending reboot and the server will reboot."
    }
    Else
    {
      Write-Verbose -Message 'Reboot not needed'
    }
        
    Write-Verbose -Message "Patching Done for $ComputerName"
    $speak.Speak("$ComputerName is up to date on patches")
    $speak.Dispose()
  }
        
  End
  {
  }
}
