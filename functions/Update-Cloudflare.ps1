#requires -version 4.0
#requires -RunAsAdministrator

C:\Cloudflared\cloudflared\bin\cloudflared.exe service uninstall
C:\Cloudflared\cloudflared\bin\cloudflared.exe update
C:\Cloudflared\cloudflared\bin\cloudflared.exe service install
Write-Host "Adding custom ImagePath to for Cloudflared to point to C:\Cloudflared\config.yml"
C:\Cloudflared\cloudflared\Resources\ImagePath.reg
Start-Service cloudflared