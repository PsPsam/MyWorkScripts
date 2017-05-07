Function Test-WSManCredSSP
# Enable double hop for Powershell (Is there a better way?)
{
	if ((Get-Item -Path WSMan:\localhost\Client\Auth\CredSSP).value -eq $false) 
	{
		#enabla credspp
		Enable-WSManCredSSP -Role client -DelegateComputer *.Default.com
	}
	else
	{
		$true
	}
}  # Function Test Test-WSManCredSSP done