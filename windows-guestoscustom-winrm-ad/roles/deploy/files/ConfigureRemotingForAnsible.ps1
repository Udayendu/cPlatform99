# Get the hostname
$HostName = hostname

# Generate the new self-signed certificate
$NewCert=New-SelfSignedCertificate -DnsName $HostName -CertStoreLocation Cert:\LocalMachine\My | Tee-Object -FilePath "C:\SetupWinRM.log" -Append

# Collect the thumbprint
$ThumbPrint=($Newcert.Thumbprint) | Tee-Object -FilePath "C:\SetupWinRM.log" -Append

# Configure the WinRM to listen on HTTPS
Write-Output "winrm create " | Tee-Object -FilePath "C:\SetupWinRM.log" -Append
winrm create winrm/config/Listener?Address=*+Transport=HTTPS "@{Hostname=""$HostName""; CertificateThumbprint=""$ThumbPrint""}" | Tee-Object -FilePath "C:\SetupWinRM.log" -Append
winrm set winrm/config/service '@{AllowUnencrypted="true"}'

# Write a firewall rule to open 5986
Write-Output "netsh change " | Tee-Object -FilePath "C:\SetupWinRM.log" -Append
netsh advfirewall firewall add rule name="Windows Remote Management (HTTPS-In)" dir=in action=allow protocol=TCP localport=5986 | Tee-Object -FilePath "C:\SetupWinRM.log" -Append

# Enable CredSSP
Write-Output "enable credssp " | Tee-Object -FilePath "C:\SetupWinRM.log" -Append
Set-Item -Path "WSMan:\localhost\service\auth\credSSP" -Value $True | Tee-Object -FilePath "C:\SetupWinRM.log" -Append
Enable-WSManCredSSP -Role Server -Force | Tee-Object -FilePath "C:\SetupWinRM.log" -Append
Write-Output "enable credssp done " | Tee-Object -FilePath "C:\SetupWinRM.log" -Append

# Restart WinRM
Write-Output "restart winrm " | Tee-Object -FilePath "C:\SetupWinRM.log" -Append
Restart-Service WinRM | Tee-Object -FilePath "C:\SetupWinRM.log" -Append
Write-Output "restart winrm done " | Tee-Object -FilePath "C:\SetupWinRM.log" -Append

