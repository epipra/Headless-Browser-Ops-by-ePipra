#!/usr/bin/env bash
# Daily release cutter: if there are new commits since the last release tag,
# promote CHANGELOG.md's "Unreleased" section into a dated CalVer release,
# tag it, push, and publish a GitHub Release. No-op if nothing changed.
set -euo pipefail

REPO_DIR="/root/browser-tasks-automation"
TOKEN_FILE="/root/.config/browser-tasks-automation/github_token"
cd "$REPO_DIR"

if [ -f "$TOKEN_FILE" ]; then
  export GITHUB_TOKEN
  GITHUB_TOKEN="$(cat "$TOKEN_FILE")"
else
  echo "Missing $TOKEN_FILE -- create a fine-grained GitHub PAT (Contents: read/write) for this repo and save it there." >&2
  exit 1
fi

LAST_TAG="$(git describe --tags --abbrev=0 2>/dev/null || true)"

if [ -n "$LAST_TAG" ]; then
  NEW_COMMITS="$(git rev-list "${LAST_TAG}..HEAD" --count)"
  if [ "$NEW_COMMITS" -eq 0 ]; then
    echo "No new commits since $LAST_TAG. Nothing to release."
    exit 0
  fi
fi

VERSION="v$(date +%Y.%m.%d)"
SUFFIX=2
while git rev-parse "$VERSION" >/dev/null 2>&1; do
  VERSION="v$(date +%Y.%m.%d)-${SUFFIX}"
  SUFFIX=$((SUFFIX + 1))
done

TODAY="$(date +%Y-%m-%d)"
awk -v version="$VERSION" -v today="$TODAY" '
  /^## Unreleased/ && !done { print; print ""; print "## " version " - " today; done=1; next }
  { print }
' CHANGELOG.md > CHANGELOG.md.tmp
mv CHANGELOG.md.tmp CHANGELOG.md

git add CHANGELOG.md
git commit -m "chore: release ${VERSION}"
git tag "$VERSION"
git push origin main
git push origin "$VERSION"

NOTES_FILE="$(mktemp)"
trap 'rm -f "$NOTES_FILE"' EXIT
awk -v version="$VERSION" '
  $0 ~ "^## " version { found=1; next }
  found && /^## / { exit }
  found { print }
' CHANGELOG.md > "$NOTES_FILE"

gh release create "$VERSION" --title "$VERSION" --notes-file "$NOTES_FILE"

echo "Released $VERSION."
