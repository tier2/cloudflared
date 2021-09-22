#requires -version 4.0
#requires -RunAsAdministrator
Set-ExecutionPolicy -ExecutionPolicy bypass -Scope CurrentUser
Install-Module powershell-yaml
Import-Module powershell-yaml

Write-Host "PowerShell is run as administrator." -ForegroundColor Green

# Set working location
Write-Host "Setting directory to C:\Cloudflared."
Set-Location -Path C:\Cloudflared

# Authenticate Cloudflare
Write-Host "Checking if Cloudflare has authenticated."
$CloudflareAuthentication = "C:\Users\$($env:username)\.cloudflared\cert.pem"

if ($CloudflareAuthentication) {
    Write-Host "Cloudflare has already been authenticated." -ForegroundColor Green
}
else {
    Write-Host "Cloudlfare needs to be authenticated, attempting now..." -ForegroundColor Yellow
    .\cloudflared.exe login
}



# Create System .cloudflared folder
Write-Host "Creating system profile for Cloudflare authentication files."
$SystemPath = Test-Path -Path C:\Windows\System32\config\systemprofile\.cloudflared
if (!$SystemPath) {

    mkdir C:\Windows\System32\config\systemprofile\.cloudflared
    Write-Host "Directory created!"
}
else {
    Write-Host "Directory already exists, moving on..."
}

# Copy Authentication files 
Write-Host "Copying authentication files into system profile."
$CloudflareSystemAuthentication = Test-Path -Path C:\Windows\System32\config\systemprofile\.cloudflared\cert.pem
if ($CloudflareSystemAuthentication) {
    Write-Host "File already exists in system profile, moving on..."
}
else {
  
    Copy-Item -Path "C:\Users\$($env:username)\.cloudflared\cert.pem" -Destination C:\Windows\System32\config\systemprofile\.cloudflared
    Write-Host "File copied!"
}

# Check for and create tunnel
Write-Host "Checking for existing tunnel file."
$TunnelFile = Test-Path -Path "C:\Users\$($env:username)\.cloudflared\*.json"

if (!$TunnelFile) {
    Write-Host "Creating tunnel with Cloudflare"
    $TunnelName = Read-Host -Prompt "Enter a name for your tunnel"
    if ($TunnelName) {
        .\cloudflared.exe tunnel create $TunnelName
    }
}
    



# Get PID from JSON file
$TunnelFile = Test-Path -Path "C:\Users\$($env:username)\.cloudflared\*.json"
if ($TunnelFile) {
    $JsonFile = Get-ChildItem -Path "C:\Users\$($env:username)\.cloudflared\" | Where-Object { $_.name -match ".json" }
    $PIDName = $JsonFile.name.split(".")
    $PIDName = $PIDName[0]
}

# Checking for Config.yml file
$DoesConfigExist = Test-Path -Path C:\Cloudlfared\config.yml

if (!$PIDNAME) {
    write-host "Doesn't look like the login process ran correctly, please try again."
    break
}

if ($DoesConfigExist) {
    $RawYaml = Get-Content -Path C:\Cloudlfared\config.yml -Raw
    $Yaml = ConvertFrom-Yaml $RawYaml

    $Yaml.tunnel = $PIDName
    $Yaml["credentials-file"] = "C:\Users\$($env:username)\.cloudflared\$($PIDName).json"
    
    # Backup existing config file
    $BackupDate = Get-Date -Format "MMddyyyyHHmm"
    Rename-Item -Path C:\Cloudflared\config.yml -NewName "C:\Cloudflare\backups\config-$($BackupDate).yml"

    ConvertTo-Yaml $Yaml | Out-file C:\Cloudlfared\config.yml
}
else {
    # Create Base Config with tunnel ID and link to JSON file.
    $BaseConfig = @{
        "credentials-file" = "C:\Users\$($env:username)\.cloudflared\$($PIDName).json"
        tunnel             = $PIDName
        originRequest      = @{
            noTLSVerify = $true
        }
        logfile = "C:\logs\cloudflared.log"

    } | ConvertTo-Yaml | Out-File "C:\Cloudflared\config.yml"


}


# Install image path
Write-Host "Adding custom ImagePath to for Cloudflared to point to C:\Cloudflared\config.yml"
.\Resources\ImagePath.reg
