#!/usr/bin/env bash
if [ -z "$AGENT_BROWSER_ALLOWED_DOMAINS" ]; then
  echo "No domain allowlist is currently set (all domains allowed)."
  echo "Set one in your .env or shell profile before running unattended tasks."
else
  echo "Current allowed domains:"
  echo "$AGENT_BROWSER_ALLOWED_DOMAINS" | tr ',' '\n' | sed 's/^/  - /'
fi
