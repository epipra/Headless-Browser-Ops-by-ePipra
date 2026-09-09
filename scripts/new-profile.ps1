param([string]$Name)
if (-not $Name) {
    Write-Host "Usage: .\scripts\new-profile.ps1 <profile-name>"
    exit 1
}
$ProfilePath = "$Env:USERPROFILE\.agent-browser-profiles\$Name"
New-Item -ItemType Directory -Force -Path $ProfilePath | Out-Null
Write-Host "Profile created: $ProfilePath"
Write-Host ""
Write-Host "Use it with:"
Write-Host "  agent-browser open <url> --profile `"$ProfilePath`""
