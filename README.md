<#
.SYNOPSIS
    Generates a PowerShell script to manage firewall rules for a specified port.

.DESCRIPTION
    This script generates another PowerShell script with the logic to either open or close a specified port in the firewall.
    The generated script accepts `--open` or `--close` parameters to perform the corresponding action on the port.

.PARAMETER Port
    The port number to manage. This parameter is required.

.EXAMPLE
    .\Generate-FirewallScript.ps1 -Port 9000
    This will generate a script file named `port-9000.ps1` which includes logic to open or close port 9000.

.NOTES
    File Name: Generate-FirewallScript.ps1
    Author: [Your Name]
    Date: [Date]
#>

# Script Generator Function
function Generate-FirewallScript {
    param (
        [string]$Port
    )

    if (-not $Port) {
        Write-Host "Port parameter is required."
        return
    }

    $fileName = "port-$Port.ps1"

    $scriptContent = @"
<#
.SYNOPSIS
    Manages firewall rules for port $Port.

.DESCRIPTION
    This script allows you to open or close a specified port in the firewall.
    Use the `--open` parameter to allow the port or the `--close` parameter to remove the rules for the port.

.PARAMETER Open
    If specified, the script will open the port by allowing inbound and outbound traffic.

.PARAMETER Close
    If specified, the script will close the port by removing existing rules.

.EXAMPLE
    .\port-9000.ps1 -Open
    This will open port 9000 by allowing inbound and outbound traffic.

    .\port-9000.ps1 -Close
    This will close port 9000 by removing the existing rules.
#>

param (
    [switch]`$Open,
    [switch]`$Close
)

if (`$Open -and `$Close) {
    Write-Host "You cannot use both --open and --close at the same time."
    exit
}

if (-not (`$Open -or `$Close)) {
    Write-Host "You must specify either --open or --close."
    exit
}

if (`$Open) {
    # Open Port
    New-NetFirewallRule -DisplayName "Allow Port $Port Inbound" -Direction Inbound -Protocol TCP -LocalPort $Port -Action Allow -Profile Any
    New-NetFirewallRule -DisplayName "Allow Port $Port Outbound" -Direction Outbound -Protocol TCP -LocalPort $Port -Action Allow -Profile Any
    Write-Host "Port $Port is allowed for inbound and outbound traffic."
}

if (`$Close) {
    # Close Port
    Remove-NetFirewallRule -DisplayName "Allow Port $Port Inbound" -ErrorAction SilentlyContinue
    Remove-NetFirewallRule -DisplayName "Allow Port $Port Outbound" -ErrorAction SilentlyContinue
    Write-Host "Rules for port $Port have been removed."
}
"@

    Set-Content -Path $fileName -Value $scriptContent
    Write-Host "Script '$fileName' has been generated."
}

# Get user input
$Port = Read-Host "Enter the port number"

# Generate the script
Generate-FirewallScript -Port $Port
