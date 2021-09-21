#requires -version 4.0
#requires -RunAsAdministrator

# Install Service
Write-Host "Install Cloudflared Service."
C:\Cloudflared\cloudflared\bin\cloudflared.exe service install

# Start Service
$Service = Get-Service -Name "cloudflared"

if ($Service.Status -ne "Running") {
    Stop-Service -Name "cloudflared"
}
else {
    Stop-Service -Name "cloudflared"
}

Write-Host "Adding custom ImagePath to for Cloudflared to point to C:\Cloudflared\config.yml"
C:\Cloudflared\cloudflared\Resources\ImagePath.reg