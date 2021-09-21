#requires -version 4.0
#requires -RunAsAdministrator
Install-Module powershell-yaml
Install-Module -Name "PSWriteColor"
Import-Module powershell-yaml
Import-Module -Name "PSWriteColor"

$ConfigFile = Test-Path -Path C:\Cloudflared\config.yml
if (!$ConfigFile) {
    Write-Color "Could not find config file at C:\Cloudflared\config.yml, please check it exists." -Color Red
    Break
}
$RawConfigFile = Get-Content -Path C:\Cloudflared\config.yml -Raw
# $RawConfigFile = Get-Content -Path config.yml -Raw
$Yaml = ConvertFrom-Yaml $RawConfigFile

Write-Host "Current ingress rules are:"
foreach ($rule in $Yaml.ingress) {
    if ($rule.service -eq "http_status:404") {
        Write-Host "Default catch all rule will report HTTP Status 404, this is expected." -ForegroundColor Yellow
    }
    else {
        Write-Color -Text "Hostname ", "$($rule.hostname) ", "points to the service ", "$($rule.service)" -Color White, Green, White, Green
    }
    
}
while (($RepeatNewRule -ne "N") -or ( $RepeatNewRule -ne "n")) {
    $AddNewRule = Read-Host -Prompt "Would you like to add a new rule? Y/N"
    while (($AddNewRule -ne "Y") -or ($AddNewRule -ne "y")) {
    

        if (($AddNewRule -ne "Y") -or ($AddNewRule -ne "y") -or ($addNewRule -ne "n") -or ($addNewRule -ne "n")) {
            Write-Host "Please enter Y or N"
            $AddNewRule = Read-Host -Prompt "Would you like to add a new rule? Y\N"
        }

        if (($AddNewRule -eq "N") -or ($AddNewRule -eq "n")) {
            Write-Host "Ok, exiting now..."
            break
        }

    
    }
    if (($AddNewRule -eq "Y") -or ($AddNewRule -eq "y")) {
        do {
            $GenerateHostname = Read-Host "Would you like to generate a random hostname? Y\N (Recommended for non-public resources)"
        }until(($GenerateHostname -eq "Y") -or ($GenerateHostname -eq "y") -or ($GenerateHostname -eq "N") -or ($GenerateHostname -eq "n"))
        
        if (($GenerateHostname -eq "Y") -or ($GenerateHostname -eq "y")) {
            $domain = Read-Host "Enter the domain registered in Cloudflare"
            $uuid = New-Guid
            $Hostname = "$($uuid).$($domain)"
        }
        else {
            $Hostname = Read-Host -Prompt "What is the public hostname that will be used for accessing the service?"
        }

        
        $ServiceType = Read-Host -Prompt "What service will be used? e.g http, https, ssh, rdp"
        $LocalService = Read-Host -Prompt "What is the local IP address or hostname of the service?"
        $LocalPort = Read-Host -Prompt "What is the port of the local service?"

        $DefinedService = "$($ServiceType)://$($LocalService):$($LocalPort)"

        $CheckDefinedService = Read-Host -Prompt "You want to direct traffic pointing to $($Hostname) to $($DefinedService)? Y\N"

        if ($CheckDefinedService) {
            $AddToYaml = @{
                hostname = $Hostname
                service  = $DefinedService
            }

            $yaml.ingress = @($AddToYaml) + $yaml.ingress
        }
        $AddNewRule = ""
        $RepeatNewRule = Read-Host "Rule has been added, would you like to add another rule? Y\N"
    }
}
if (($RepeatNewRule -eq "N") -or ($RepeatNewRule -eq "n")) {
    $SaveAndApply = ""
    $YamlOutput = ConvertTo-Yaml $Yaml

    Write-Host "New config is:" -ForegroundColor Green
    Write-Host $YamlOutput -ForegroundColor Green

    while (($SaveAndApply -ne "Y") -or ($SaveAndApply -ne "y")) {
        $SaveAndApply = Read-Host "Would you like to save the config and restart Cloudflare Tunnel to apply changes? Y\N"
        if (($SaveAndApply -eq "N") -or ($SaveAndApply -eq "n")) {
            $ConfirmExit = Read-Host -Prompt "Are you sure you want to exit, nothing be applied to the existing config? Y\N"
            if (($ConfirmExit -eq "Y") -or ($ConfirmExit -eq "y")) {
                Write-Host "Ok, exiting now..."
                break
            }
        }
    }
    
    if (($SaveAndApply -eq "Y") -or ($SaveAndApply -eq "y")) {
        $BackupDirectory = Test-Path C:\Cloudflared\backups
        if(!$BackupDirectory){
            New-Item -Path "c:\cloudflared\" -Name "backups" -ItemType "directory"
        }
        $BackupDate = Get-Date -Format "MMddyyyyHHmm"
        Write-Host "Backuping config to C:\Cloudflared\backups\config_backup_$($BackupDate).yml" -ForegroundColor Green
        Copy-Item -Path C:\Cloudflared\config.yml -Destination "C:\Cloudflared\backups\$($BackupDate).yml"
        Write-Host "Saving config to C:\Clouflared\config.yml" -ForegroundColor Green
        $YamlOutput > C:\Cloudflared\config.yml
        Write-Host "Restarting Cloudflare Tunnel Service" -ForegroundColor Yellow
        Restart-Service -name "cloudflared"
        Write-Host "Add the following records to the Cloudflare DNS Portal:" -ForegroundColor Yellow
        Write-Host "Type: CNAME"  -ForegroundColor Yellow
        Write-Host "Name: $($Hostname)"  -ForegroundColor Yellow
        Write-Host "Target: $($yaml.tunnel).cfargotunnel.com"  -ForegroundColor Yellow
        Write-Host "Proxied: YES"  -ForegroundColor Yellow
        Write-Host "All done, exiting..."  -ForegroundColor Yellow
    }


}
