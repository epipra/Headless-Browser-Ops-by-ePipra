# Setup Guide

## Prerequisites

- Node.js 18 or later
- Google Chrome
- Git

## Linux / macOS

```bash
git clone <your-repo-url>
cd browser-tasks-automation
bash install/install.sh
```

## Windows (PowerShell)

```powershell
git clone <your-repo-url>
cd browser-tasks-automation
powershell -ExecutionPolicy Bypass -File install/install.ps1
```

## Verify the install

```bash
agent-browser open https://example.com
agent-browser snapshot -i
agent-browser close
```

You should see a checkmark confirming the page loaded, a list of page elements
with reference IDs, and a confirmation that the browser closed.

## Set your domain allowlist

Edit `.env` (created from `.env.example` during install) and set:

```
AGENT_BROWSER_ALLOWED_DOMAINS=yourdomain.com,anotherdomain.com
```

Load it into your shell:

```bash
export $(grep -v '^#' .env | xargs)
```

Or on Windows PowerShell:

```powershell
Get-Content .env | Where-Object { $_ -notmatch '^#' } | ForEach-Object {
    $name, $value = $_.Split('=', 2)
    if ($name) { [Environment]::SetEnvironmentVariable($name, $value) }
}
```

See `docs/SECURITY.md` for why this matters before running unattended tasks.
