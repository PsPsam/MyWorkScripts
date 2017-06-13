#Define Server
$WindowsFeatureNotInstalled = @(
  #  $installed = Get-WindowsFeature | where installed -like $false
  #  foreach ($i in $installed) {
  #    $name = $i.name
  #    write-host "@{Feature = '$name'}"
  #  }
  @{Feature = 'AD-Certificate'}
  @{Feature = 'ADCS-Cert-Authority'}
  @{Feature = 'ADCS-Enroll-Web-Pol'}
  @{Feature = 'ADCS-Enroll-Web-Svc'}
  @{Feature = 'ADCS-Web-Enrollment'}
  @{Feature = 'ADCS-Device-Enrollment'}
  @{Feature = 'ADCS-Online-Cert'}
  @{Feature = 'AD-Domain-Services'}
  @{Feature = 'ADFS-Federation'}
  @{Feature = 'ADLDS'}
  @{Feature = 'ADRMS'}
  @{Feature = 'ADRMS-Server'}
  @{Feature = 'ADRMS-Identity'}
  @{Feature = 'DeviceHealthAttestationService'}
  @{Feature = 'DHCP'}
  @{Feature = 'DNS'}
  @{Feature = 'Fax'}
  @{Feature = 'File-Services'}
  @{Feature = 'FS-FileServer'}
  @{Feature = 'FS-BranchCache'}
  @{Feature = 'FS-Data-Deduplication'}
  @{Feature = 'FS-DFS-Namespace'}
  @{Feature = 'FS-DFS-Replication'}
  @{Feature = 'FS-Resource-Manager'}
  @{Feature = 'FS-VSS-Agent'}
  @{Feature = 'FS-iSCSITarget-Server'}
  @{Feature = 'iSCSITarget-VSS-VDS'}
  @{Feature = 'FS-NFS-Service'}
  @{Feature = 'FS-SyncShareService'}
  @{Feature = 'HostGuardianServiceRole'}
  @{Feature = 'Hyper-V'}
  @{Feature = 'MultiPointServerRole'}
  @{Feature = 'NPAS'}
  @{Feature = 'Print-Services'}
  @{Feature = 'Print-Server'}
  @{Feature = 'Print-Scan-Server'}
  @{Feature = 'Print-Internet'}
  @{Feature = 'Print-LPD-Service'}
  @{Feature = 'RemoteAccess'}
  @{Feature = 'DirectAccess-VPN'}
  @{Feature = 'Routing'}
  @{Feature = 'Web-Application-Proxy'}
  @{Feature = 'Remote-Desktop-Services'}
  @{Feature = 'RDS-Connection-Broker'}
  @{Feature = 'RDS-Gateway'}
  @{Feature = 'RDS-Licensing'}
  @{Feature = 'RDS-RD-Server'}
  @{Feature = 'RDS-Web-Access'}
  @{Feature = 'RDS-Virtualization'}
  @{Feature = 'Web-Server'}
  @{Feature = 'Web-WebServer'}
  @{Feature = 'Web-Common-Http'}
  @{Feature = 'Web-Default-Doc'}
  @{Feature = 'Web-Dir-Browsing'}
  @{Feature = 'Web-Http-Errors'}
  @{Feature = 'Web-Static-Content'}
  @{Feature = 'Web-Http-Redirect'}
  @{Feature = 'Web-DAV-Publishing'}
  @{Feature = 'Web-Health'}
  @{Feature = 'Web-Http-Logging'}
  @{Feature = 'Web-Custom-Logging'}
  @{Feature = 'Web-Log-Libraries'}
  @{Feature = 'Web-ODBC-Logging'}
  @{Feature = 'Web-Request-Monitor'}
  @{Feature = 'Web-Http-Tracing'}
  @{Feature = 'Web-Performance'}
  @{Feature = 'Web-Stat-Compression'}
  @{Feature = 'Web-Dyn-Compression'}
  @{Feature = 'Web-Security'}
  @{Feature = 'Web-Filtering'}
  @{Feature = 'Web-Basic-Auth'}
  @{Feature = 'Web-CertProvider'}
  @{Feature = 'Web-Client-Auth'}
  @{Feature = 'Web-Digest-Auth'}
  @{Feature = 'Web-Cert-Auth'}
  @{Feature = 'Web-IP-Security'}
  @{Feature = 'Web-Url-Auth'}
  @{Feature = 'Web-Windows-Auth'}
  @{Feature = 'Web-App-Dev'}
  @{Feature = 'Web-Net-Ext'}
  @{Feature = 'Web-Net-Ext45'}
  @{Feature = 'Web-AppInit'}
  @{Feature = 'Web-ASP'}
  @{Feature = 'Web-Asp-Net'}
  @{Feature = 'Web-Asp-Net45'}
  @{Feature = 'Web-CGI'}
  @{Feature = 'Web-ISAPI-Ext'}
  @{Feature = 'Web-ISAPI-Filter'}
  @{Feature = 'Web-Includes'}
  @{Feature = 'Web-WebSockets'}
  @{Feature = 'Web-Ftp-Server'}
  @{Feature = 'Web-Ftp-Service'}
  @{Feature = 'Web-Ftp-Ext'}
  @{Feature = 'Web-Mgmt-Tools'}
  @{Feature = 'Web-Mgmt-Console'}
  @{Feature = 'Web-Mgmt-Compat'}
  @{Feature = 'Web-Metabase'}
  @{Feature = 'Web-Lgcy-Mgmt-Console'}
  @{Feature = 'Web-Lgcy-Scripting'}
  @{Feature = 'Web-WMI'}
  @{Feature = 'Web-Scripting-Tools'}
  @{Feature = 'Web-Mgmt-Service'}
  @{Feature = 'WDS'}
  @{Feature = 'WDS-Deployment'}
  @{Feature = 'WDS-Transport'}
  @{Feature = 'ServerEssentialsRole'}
  @{Feature = 'UpdateServices'}
  @{Feature = 'UpdateServices-WidDB'}
  @{Feature = 'UpdateServices-Services'}
  @{Feature = 'UpdateServices-DB'}
  @{Feature = 'VolumeActivation'}
  @{Feature = 'NET-Framework-Features'}
  @{Feature = 'NET-Framework-Core'}
  @{Feature = 'NET-HTTP-Activation'}
  @{Feature = 'NET-Non-HTTP-Activ'}
  @{Feature = 'NET-Framework-45-ASPNET'}
  @{Feature = 'NET-WCF-HTTP-Activation45'}
  @{Feature = 'NET-WCF-MSMQ-Activation45'}
  @{Feature = 'NET-WCF-Pipe-Activation45'}
  @{Feature = 'NET-WCF-TCP-Activation45'}
  @{Feature = 'BITS'}
  @{Feature = 'BITS-IIS-Ext'}
  @{Feature = 'BITS-Compact-Server'}
  @{Feature = 'BitLocker'}
  @{Feature = 'BitLocker-NetworkUnlock'}
  @{Feature = 'BranchCache'}
  @{Feature = 'NFS-Client'}
  @{Feature = 'Containers'}
  @{Feature = 'Data-Center-Bridging'}
  @{Feature = 'Direct-Play'}
  @{Feature = 'EnhancedStorage'}
  @{Feature = 'Failover-Clustering'}
  @{Feature = 'GPMC'}
  @{Feature = 'DiskIo-QoS'}
  @{Feature = 'Web-WHC'}
  @{Feature = 'Internet-Print-Client'}
  @{Feature = 'IPAM'}
  @{Feature = 'ISNS'}
  @{Feature = 'LPR-Port-Monitor'}
  @{Feature = 'ManagementOdata'}
  @{Feature = 'Server-Media-Foundation'}
  @{Feature = 'MSMQ'}
  @{Feature = 'MSMQ-Services'}
  @{Feature = 'MSMQ-Server'}
  @{Feature = 'MSMQ-Directory'}
  @{Feature = 'MSMQ-HTTP-Support'}
  @{Feature = 'MSMQ-Triggers'}
  @{Feature = 'MSMQ-Multicasting'}
  @{Feature = 'MSMQ-Routing'}
  @{Feature = 'MSMQ-DCOM'}
  @{Feature = 'Multipath-IO'}
  @{Feature = 'MultiPoint-Connector'}
  @{Feature = 'MultiPoint-Connector-Services'}
  @{Feature = 'MultiPoint-Tools'}
  @{Feature = 'NLB'}
  @{Feature = 'PNRP'}
  @{Feature = 'qWave'}
  @{Feature = 'CMAK'}
  @{Feature = 'Remote-Assistance'}
  @{Feature = 'RDC'}
  @{Feature = 'RSAT'}
  @{Feature = 'RSAT-Feature-Tools'}
  @{Feature = 'RSAT-SMTP'}
  @{Feature = 'RSAT-Feature-Tools-BitLocker'}
  @{Feature = 'RSAT-Feature-Tools-BitLocker-RemoteAdminTool'}
  @{Feature = 'RSAT-Feature-Tools-BitLocker-BdeAducExt'}
  @{Feature = 'RSAT-Bits-Server'}
  @{Feature = 'RSAT-DataCenterBridging-LLDP-Tools'}
  @{Feature = 'RSAT-Clustering'}
  @{Feature = 'RSAT-Clustering-Mgmt'}
  @{Feature = 'RSAT-Clustering-PowerShell'}
  @{Feature = 'RSAT-Clustering-AutomationServer'}
  @{Feature = 'RSAT-Clustering-CmdInterface'}
  @{Feature = 'IPAM-Client-Feature'}
  @{Feature = 'RSAT-NLB'}
  @{Feature = 'RSAT-Shielded-VM-Tools'}
  @{Feature = 'RSAT-SNMP'}
  @{Feature = 'RSAT-Storage-Replica'}
  @{Feature = 'RSAT-WINS'}
  @{Feature = 'RSAT-Role-Tools'}
  @{Feature = 'RSAT-AD-Tools'}
  @{Feature = 'RSAT-AD-PowerShell'}
  @{Feature = 'RSAT-ADDS'}
  @{Feature = 'RSAT-AD-AdminCenter'}
  @{Feature = 'RSAT-ADDS-Tools'}
  @{Feature = 'RSAT-ADLDS'}
  @{Feature = 'RSAT-Hyper-V-Tools'}
  @{Feature = 'Hyper-V-Tools'}
  @{Feature = 'Hyper-V-PowerShell'}
  @{Feature = 'RSAT-RDS-Tools'}
  @{Feature = 'RSAT-RDS-Gateway'}
  @{Feature = 'RSAT-RDS-Licensing-Diagnosis-UI'}
  @{Feature = 'RDS-Licensing-UI'}
  @{Feature = 'UpdateServices-RSAT'}
  @{Feature = 'UpdateServices-API'}
  @{Feature = 'UpdateServices-UI'}
  @{Feature = 'RSAT-ADCS'}
  @{Feature = 'RSAT-ADCS-Mgmt'}
  @{Feature = 'RSAT-Online-Responder'}
  @{Feature = 'RSAT-ADRMS'}
  @{Feature = 'RSAT-DHCP'}
  @{Feature = 'RSAT-DNS-Server'}
  @{Feature = 'RSAT-Fax'}
  @{Feature = 'RSAT-File-Services'}
  @{Feature = 'RSAT-DFS-Mgmt-Con'}
  @{Feature = 'RSAT-FSRM-Mgmt'}
  @{Feature = 'RSAT-NFS-Admin'}
  @{Feature = 'RSAT-NPAS'}
  @{Feature = 'RSAT-Print-Services'}
  @{Feature = 'RSAT-RemoteAccess'}
  @{Feature = 'RSAT-RemoteAccess-Mgmt'}
  @{Feature = 'RSAT-RemoteAccess-PowerShell'}
  @{Feature = 'WDS-AdminPack'}
  @{Feature = 'RSAT-VA-Tools'}
  @{Feature = 'RPC-over-HTTP-Proxy'}
  @{Feature = 'Setup-and-Boot-Event-Collection'}
  @{Feature = 'Simple-TCPIP'}
  @{Feature = 'FS-SMBBW'}
  @{Feature = 'SMTP-Server'}
  @{Feature = 'SNMP-Service'}
  @{Feature = 'SNMP-WMI-Provider'}
  @{Feature = 'Telnet-Client'}
  @{Feature = 'TFTP-Client'}
  @{Feature = 'WebDAV-Redirector'}
  @{Feature = 'Biometric-Framework'}
  @{Feature = 'Windows-Identity-Foundation'}
  @{Feature = 'Windows-Internal-Database'}
  @{Feature = 'PowerShell-V2'}
  @{Feature = 'DSC-Service'}
  @{Feature = 'WindowsPowerShellWebAccess'}
  @{Feature = 'WAS'}
  @{Feature = 'WAS-Process-Model'}
  @{Feature = 'WAS-NET-Environment'}
  @{Feature = 'WAS-Config-APIs'}
  @{Feature = 'Search-Service'}
  @{Feature = 'Windows-Server-Backup'}
  @{Feature = 'Migration'}
  @{Feature = 'WindowsStorageManagementService'}
  @{Feature = 'Windows-TIFF-IFilter'}
  @{Feature = 'WinRM-IIS-Ext'}
  @{Feature = 'WINS'}
  @{Feature = 'Wireless-Networking'}
  @{Feature = 'FabricShieldedTools'}
  @{Feature = 'XPS-Viewer'}
  @{Feature = 'FS-SMB1'}	
)
$windowsFeaturesInstalled = @(
  #  $installed = Get-WindowsFeature | where installed -like $true
  #  foreach ($i in $installed) {
  #    $name = $i.name
  #    write-host "@{Feature = '$name'}"
  #  }
  @{Feature = 'FileAndStorage-Services'}
  @{Feature = 'Storage-Services'}
  @{Feature = 'NET-Framework-45-Features'}
  @{Feature = 'NET-Framework-45-Core'}
  @{Feature = 'NET-WCF-Services45'}
  @{Feature = 'NET-WCF-TCP-PortSharing45'}
  #@{Feature = 'FS-SMB1'}
  @{Feature = 'Windows-Defender-Features'}
  @{Feature = 'Windows-Defender'}
  @{Feature = 'Windows-Defender-Gui'}
  @{Feature = 'PowerShellRoot'}
  @{Feature = 'PowerShell'}
  @{Feature = 'PowerShell-ISE'}
  @{Feature = 'WoW64-Support'}
)
$Programs = @(
  @{
    Name = 'Program A'
  }
  @{
    Name = 'Program B'
  }
  @{
    Name = 'Program C'
  }
)
#End Define Server
$WindowsFeatures = Get-WindowsFeature | Where-Object installed -like $true
$installedprograms = Get-ItemProperty -Path HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object -Property DisplayName

Describe -Name 'Server configuration' -Fixture {
  Context -Name 'Windows Feature that should be installed' -Fixture {
    It -name 'Should have <Feature> installed' -TestCases $windowsFeaturesInstalled -test {
      param($Feature)
      $WindowsFeatures.Name -contains $Feature | Should Be $True
    }
  }

  Context -Name 'Windows Feature that should Not be installed' -Fixture {
    It -name 'Should NOT have <Feature> installed' -TestCases $WindowsFeatureNotInstalled  -test {
      param($Feature)
      $WindowsFeatures.Name -contains $Feature | Should Be $False
    }
  }

  Context -Name 'Default programs that should be installed' -Fixture {       
    It -name 'Should have <Name> installed' -TestCases $Programs -test {
      param($name)
      $installedprograms.DisplayName -contains $name | Should be $True
    }   
  }

  Context -Name 'Should have folders created' -Fixture {
    It -Name 'Should have folder c:\windows\sodra' {
      Test-Path -Path C:\Windows\Sodra -IsValid | Should be $True	
    }
  }
}