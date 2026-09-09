# Browser Tasks Automation

A reusable, portable browser automation toolkit built on
[agent-browser](https://www.npmjs.com/package/agent-browser). Works headless,
with no MCP server registration needed. Installs the same way on a VPS, a
local Linux/macOS machine, or Windows.

## Quick Start

### Linux / macOS

```bash
git clone <your-repo-url>
cd browser-tasks-automation
bash install/install.sh
```

### Windows (PowerShell)

```powershell
git clone <your-repo-url>
cd browser-tasks-automation
powershell -ExecutionPolicy Bypass -File install/install.ps1
```

### Verify it worked

```bash
agent-browser open https://example.com
agent-browser snapshot -i
agent-browser close
```

## What's included

| Path | Purpose |
|---|---|
| `install/install.sh` | One-step installer for Linux/macOS |
| `install/install.ps1` | One-step installer for Windows |
| `scripts/new-profile.sh` / `.ps1` | Create a named, persistent browser profile |
| `scripts/check-domains.sh` | Print the current domain allowlist |
| `.env.example` | Template for your domain allowlist and optional AI key |
| `docs/SETUP.md` | Full setup walkthrough |
| `docs/USAGE.md` | Full command reference |
| `docs/PROFILES.md` | How persistent profiles and logins work |
| `docs/SECURITY.md` | Domain allowlisting, profile safety, credential handling |

## Core commands

```bash
agent-browser open <url>
agent-browser snapshot -i
agent-browser click <ref>
agent-browser fill <ref> "text"
agent-browser get text <ref>
agent-browser screenshot <path>
agent-browser close
```

Full reference in `docs/USAGE.md`.

## Before running unattended automation

1. Set `AGENT_BROWSER_ALLOWED_DOMAINS` in `.env` (see `docs/SETUP.md`)
2. Never commit anything under `profiles/` (it's gitignored already)
3. For any task requiring login, read `docs/PROFILES.md` first

## License

MIT, see `LICENSE`.
