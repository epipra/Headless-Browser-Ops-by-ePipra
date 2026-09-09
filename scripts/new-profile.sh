#!/usr/bin/env bash
# Usage: ./scripts/new-profile.sh <profile-name>
NAME="$1"
if [ -z "$NAME" ]; then
  echo "Usage: $0 <profile-name>"
  exit 1
fi
PROFILE_PATH="$HOME/.agent-browser-profiles/$NAME"
mkdir -p "$PROFILE_PATH"
echo "Profile created: $PROFILE_PATH"
echo ""
echo "Use it with:"
echo "  agent-browser open <url> --profile \"$PROFILE_PATH\""
