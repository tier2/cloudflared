#requires -version 4.0
#requires -RunAsAdministrator

taskkill -f -im cloudflared.exe
C:\Cloudflared\bin\cloudflared.exe service uninstall
.\cloudflared.exe update
C:\Cloudflared\bin\cloudflared.exe service install