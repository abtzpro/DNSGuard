# Script requires Administrator privileges
if (-NOT ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Output "This script must be run as an Administrator. Please restart the script with Administrator privileges!"
    break
}

# Set DNS servers for a given network interface to Cloudflare's
$interfaceIndex = (Get-NetAdapter | Where-Object {$_.Status -eq 'Up'}).ifIndex
Set-DnsClientServerAddress -InterfaceIndex $interfaceIndex -ServerAddresses 1.1.1.1,1.0.0.1

# Prevent interface from accepting DNS servers from DHCP
Set-DnsClient -InterfaceIndex $interfaceIndex -UseSuffixWhenRegistering $false

# Clear DNS cache
Clear-DnsClientCache

# Set the URL of the Cloudflare client
$clientUrl = "https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-windows-amd64.exe"

# Set the path where Cloudflared will be installed
$installPath = "$env:ProgramFiles\Cloudflared\cloudflared.exe"

# Download and install Cloudflared
if (!(Test-Path $installPath)) {
    New-Item -ItemType Directory -Force -Path $env:ProgramFiles\Cloudflared | Out-Null
    Invoke-WebRequest -Uri $clientUrl -OutFile $installPath
}

# Start the service to use 1.1.1.1 DNS with DoH
Start-Process -NoNewWindow -FilePath $installPath -ArgumentList "service install"

# Enforce Firewall rule to allow only DNS over HTTPS
New-NetFirewallRule -DisplayName "BlockOutboundDNS" -Direction Outbound -Protocol UDP -LocalPort 53 -Action Block
New-NetFirewallRule -DisplayName "AllowCloudflaredDNS" -Direction Outbound -Program $installPath -Action Allow

# Check if MalwareBytes is installed
$malwareBytesPath = "C:\Program Files\Malwarebytes\Anti-Malware\mbam.exe"
if (!(Test-Path $malwareBytesPath)) {
    # MalwareBytes not found, attempting to download installer
    $malwareBytesInstallerUrl = "https://downloads.malwarebytes.com/file/mb-windows"
    $installerPath = "$env:USERPROFILE\Downloads\mbsetup.exe"
    Invoke-WebRequest -Uri $malwareBytesInstallerUrl -OutFile $installerPath
    Write-Output "MalwareBytes installer downloaded to $installerPath. Please install it manually then re-run this script."
} else {
    # Run MalwareBytes scan
    & $malwareBytesPath /scan | Out-Null
}
