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
