Write-Host "=== Browser Tasks Automation - Installer (Windows) ==="
Write-Host ""

if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "Node.js not found."
    Write-Host "  winget install OpenJS.NodeJS.LTS"
    exit 1
} else {
    Write-Host "Node.js found: $(node -v)"
}

$chromePath = "$Env:ProgramFiles\Google\Chrome\Application\chrome.exe"
$chromePathX86 = "${Env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
if ((Test-Path $chromePath) -or (Test-Path $chromePathX86)) {
    Write-Host "Chrome found."
} else {
    Write-Host "Google Chrome not found."
    Write-Host "  winget install Google.Chrome"
    exit 1
}

Write-Host ""
Write-Host "Installing agent-browser CLI..."
npm install -g agent-browser

New-Item -ItemType Directory -Force -Path "$Env:USERPROFILE\.agent-browser-profiles" | Out-Null
New-Item -ItemType Directory -Force -Path "$Env:USERPROFILE\.browser-tasks-automation\logs" | Out-Null

if (-not (Test-Path ".env")) {
    Copy-Item ".env.example" ".env"
    Write-Host "Created .env from template. Edit it to set AGENT_BROWSER_ALLOWED_DOMAINS."
}

if ((Test-Path "hooks") -and (Test-Path ".git")) {
    git config core.hooksPath hooks
    Write-Host "Enabled auto-changelog git hook."
}

Write-Host ""
Write-Host "Install complete."
Write-Host "Verify with:"
Write-Host "  agent-browser open https://example.com"
Write-Host "  agent-browser snapshot -i"
Write-Host "  agent-browser close"
