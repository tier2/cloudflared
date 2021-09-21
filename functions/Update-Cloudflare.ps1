#requires -version 4.0
#requires -RunAsAdministrator
$Service = Get-Service cloudflared  -erroraction "silentlycontinue"
if($service){
    C:\Cloudflared\cloudflared\bin\cloudflared.exe service uninstall
}
$Service = Get-Service cloudflared -erroraction "silentlycontinue"
do{
    Write-host "Waiting for service to finish uninstalling..." -ForegroundColor Yellow
    $Service = Get-Service cloudflared -erroraction "silentlycontinue"
    Start-Sleep -Seconds 1
}until(!$service)
C:\Cloudflared\cloudflared\bin\cloudflared.exe update
Start-Sleep -Seconds 4
C:\Cloudflared\cloudflared\bin\cloudflared.exe service install
$Service = Get-Service cloudflared -erroraction "silentlycontinue"
do{
    Write-host "Waiting for service to finish installing..." -ForegroundColor Yellow
}until($service)
Write-Host "Adding custom ImagePath to for Cloudflared to point to C:\Cloudflared\config.yml"
Invoke-Command {reg import C:\Cloudflared\cloudflared\Resources\ImagePath.reg *>&1 | Out-Null}
$Service = Get-Service cloudflared  -erroraction "silentlycontinue"
if($service.status -eq "Running"){
    Stop-Service cloudflared
    Start-Service cloudflared

} else {
    Start-Service cloudflared
}

$Service = Get-Service cloudflared  -erroraction "silentlycontinue"
if($service.status -eq "Running"){
    Write-Host "Cloudflared Tunnel Service is running!" -ForegroundColor Green
}
