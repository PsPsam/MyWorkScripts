# describes the function Test-WSManCredSSP
Describe -Name 'Test-WSManCredSSP' -Fixture {

    #Get-item can return true ot false
    # mock (Get-Item  -Path WSMan:\localhost\Client\Auth\CredSSP).value
    $wsman = New-MockObject -type 'System.Xml.XmlElement'
   # $wsman | Add-Member -MemberType NoteProperty -Name 'CredSSP' -Value 'true'
    mock 'Enable-WSManCredSSP'
    
    Context -Name 'Get-item returing $true' {
        mock 'Get-item' {
            (Get-Item -Path WSMan:\localhost\Client\Auth\CredSSP).value -eq $true
        }

 #       Test-WSManCredSSP

        it 'Returns $true if $true' {
            'Test-WSManCredSSP' | should be $true
        } 
    }

    Context -Name 'Get-item returing $false' {
        
        mock 'Get-item' {
            (Get-Item -Path WSMan:\localhost\Client\Auth\CredSSP).value -eq $false
        }
 #       Test-WSManCredSSP

        it 'Execute enable-WSManCredSSp if $false' {
            $assMParamas = @{
                CommandName = 'Enable-WSManCredSSP'
                Times = 1
                Exactly = $true
            }
            Assert-MockCalled @assMParamas
        }
    }
}