#requires -version 4.0
#requires -RunAsAdministrator

C:\Cloudflared\cloudflared\bin\cloudflared.exe service uninstall
C:\Cloudflared\cloudflared\bin\cloudflared.exe update
C:\Cloudflared\cloudflared\bin\cloudflared.exe service install
Write-Host "Adding custom ImagePath to for Cloudflared to point to C:\Cloudflared\config.yml"
Write-Host "Adding custom ImagePath to for Cloudflared to point to C:\Cloudflared\config.yml"
Invoke-Command {reg import C:\Cloudflared\cloudflared\Resources\ImagePath.reg *>&1 | Out-Null}
$Service = Get-Service cloudflared
if($service.status -eq "Running"){
    Stop-Service cloudflared
    Start-Service cloudflared

} else {
    Start-Service cloudflared
}
