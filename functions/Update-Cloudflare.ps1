#requires -version 4.0
#requires -RunAsAdministrator

taskkill -f -im cloudflared.exe
C:\Cloudflared\cloudflared\bin\cloudflared.exe service uninstall
.\cloudflared.exe update
C:\Cloudflared\cloudflared\bin\cloudflared.exe service install