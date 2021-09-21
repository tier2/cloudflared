#requires -version 4.0
#requires -RunAsAdministrator

do {
    Write-Host "`n============= Cloudflare Setup =========================" -ForegroundColor Yellow
    Write-Host "`t1. Run the Cloudflare initial setup." -ForegroundColor Green
    Write-Host "`t2. Install the Cloudflared Windows Service." -ForegroundColor Green
    Write-Host "`t3. Update the Cloudflared Windows Service." -ForegroundColor Green
    Write-Host "`t4. Remove the Cloudflared Windows Service." -ForegroundColor Green
    Write-Host "`t5. Add a new Cloudflared Rule." -ForegroundColor Green
    Write-Host "`tQ. 'Quit'" -ForegroundColor Red
    Write-Host "========================================================" -ForegroundColor Yellow
    $choice = Read-Host "`nEnter Choice"
} until (($choice -eq '1') -or ($choice -eq '2') -or ($choice -eq '3') -or ($choice -eq '4') -or ($choice -eq '5') -or ($choice -eq 'Q') )
switch ($choice) {
    '1' {
        Write-Host "`nStarting initial setup script."
        powershell -noexit -nologo -executionpolicy bypass -File C:\Cloudflared\functions\Install-Cloudflare.ps1
    }
    '2' {
        Write-Host "`nStarting service install."
        powershell -noexit -nologo -executionpolicy bypass -File C:\Cloudflared\functions\Install-Service.ps1
    }
    '3' {
        Write-Host "`nStarting service update."
        powershell -noexit -nologo -executionpolicy bypass -File C:\Cloudflared\functions\Update-Cloudflare.ps1
    }
    '4' {
        Write-Host "`nStarting service removal.."
        powershell -noexit -nologo -executionpolicy bypass -File C:\Cloudflared\functions\Remove-Service.ps1
    }
    '5' {
        Write-Host "`nStarting rule addition."
        powershell -noexit -nologo -executionpolicy bypass -File C:\Cloudflared\functions\Add-CloudflareRule.ps1
    }
    'Q' {
        Return
    }
}