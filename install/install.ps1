Write-Host "=== Browser Tasks Automation - Installer (Windows) ==="
Write-Host ""

# 1. Check Node.js
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "Node.js not found."
    Write-Host "Install it first, then re-run this script:"
    Write-Host "  winget install OpenJS.NodeJS.LTS"
    Write-Host "  or download from https://nodejs.org"
    exit 1
} else {
    Write-Host "Node.js found: $(node -v)"
}

# 2. Check Chrome
$chromePath = "$Env:ProgramFiles\Google\Chrome\Application\chrome.exe"
$chromePathX86 = "${Env:ProgramFiles(x86)}\Google\Chrome\Application\chrome.exe"
if ((Test-Path $chromePath) -or (Test-Path $chromePathX86)) {
    Write-Host "Chrome found."
} else {
    Write-Host "Google Chrome not found."
    Write-Host "  winget install Google.Chrome"
    Write-Host "  or download from https://www.google.com/chrome"
    exit 1
}

# 3. Install agent-browser CLI
Write-Host ""
Write-Host "Installing agent-browser CLI..."
npm install -g agent-browser

# 4. Set up folders
New-Item -ItemType Directory -Force -Path "$Env:USERPROFILE\.agent-browser-profiles" | Out-Null
New-Item -ItemType Directory -Force -Path "$Env:USERPROFILE\.browser-tasks-automation\logs" | Out-Null

# 5. Set up env file
if (-not (Test-Path ".env")) {
    Copy-Item ".env.example" ".env"
    Write-Host "Created .env from template. Edit it to set AGENT_BROWSER_ALLOWED_DOMAINS."
}

Write-Host ""
Write-Host "Install complete."
Write-Host "Verify with:"
Write-Host "  agent-browser open https://example.com"
Write-Host "  agent-browser snapshot -i"
Write-Host "  agent-browser close"
