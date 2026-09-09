#!/usr/bin/env bash
set -e

echo "=== Browser Tasks Automation - Installer (Linux/macOS) ==="
echo ""

if ! command -v node &> /dev/null; then
  echo "Node.js not found."
  echo "  Linux (Debian/Ubuntu): curl -fsSL https://deb.nodesource.com/setup_20.x | bash - && apt-get install -y nodejs"
  echo "  macOS:                 brew install node"
  exit 1
else
  echo "Node.js found: $(node -v)"
fi

if command -v google-chrome &> /dev/null; then
  echo "Chrome found: $(google-chrome --version)"
elif [ -d "/Applications/Google Chrome.app" ]; then
  echo "Chrome found (macOS)."
else
  echo "Google Chrome not found."
  echo "  Linux: wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb && apt install -y ./google-chrome-stable_current_amd64.deb"
  echo "  macOS: brew install --cask google-chrome"
  exit 1
fi

echo ""
echo "Installing agent-browser CLI..."
npm install -g agent-browser

mkdir -p ~/.agent-browser-profiles
mkdir -p ~/.browser-tasks-automation/logs

if [ ! -f .env ]; then
  cp .env.example .env
  echo "Created .env from template. Edit it to set AGENT_BROWSER_ALLOWED_DOMAINS."
fi

if [ -d "hooks" ] && [ -d ".git" ]; then
  git config core.hooksPath hooks
  chmod +x hooks/* 2>/dev/null || true
  echo "Enabled auto-changelog git hook."
fi

echo ""
echo "Install complete."
echo "Verify with:"
echo "  agent-browser open https://example.com"
echo "  agent-browser snapshot -i"
echo "  agent-browser close"
