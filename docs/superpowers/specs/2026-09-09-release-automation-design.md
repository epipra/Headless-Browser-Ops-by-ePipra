# Design: Automated CalVer Releases from CHANGELOG.md

## Context

`browser-tasks-automation` already auto-maintains `CHANGELOG.md` on every
commit via `hooks/post-commit` (writes into a `## Unreleased` section). There
is no mechanism to cut a release: tag the repo, push it, and publish a
GitHub Release. This design adds that mechanism, running unattended on a
daily cron schedule managed by the VPS-wide `/root/cron-manager` tool.

## Goals

- Once a day, if new commits exist since the last release, cut a new
  release automatically: no human interaction required.
- No-op cleanly (no commit, no tag, no release) when nothing changed.
- Reuse `CHANGELOG.md` as the single source of release notes — no new
  markdown file.
- Follow existing VPS conventions: cron jobs go through `cron-manager`
  (`jobs.json` + `manage.py apply`), not raw crontab edits.

## Non-goals

- Semantic versioning / manual version bumps (CalVer only).
- Rollback/undo tooling for a bad release (out of scope; manual `gh release
  delete` + `git tag -d` is sufficient given low stakes).
- Rewriting the existing `hooks/post-commit` changelog-on-commit mechanism.

## Architecture

```
cron-manager (jobs.json: "browser-tasks-automation-release", 10 4 * * *)
        |
        v
runner.py <job_id>   -- generic wrapper: runs command, logs, Telegram notify
        |
        v
scripts/cut-release.sh   (new, lives in browser-tasks-automation repo)
        |
        +--> git describe --tags --abbrev=0   (find last release)
        +--> git rev-list <last>..HEAD --count (no-op guard)
        +--> rewrite CHANGELOG.md (Unreleased -> versioned section)
        +--> git commit / tag / push
        +--> gh release create <tag> --notes-file <extracted section>
```

## Components

### `scripts/cut-release.sh` (new)

Bash script, `set -euo pipefail`. Steps:

1. `cd` to repo root (`/root/browser-tasks-automation`).
2. `LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || true)`.
3. If `LAST_TAG` is set, count commits since it
   (`git rev-list "$LAST_TAG"..HEAD --count`); if zero, `echo "No new
   commits since $LAST_TAG."; exit 0`.
4. `VERSION="v$(date +%Y.%m.%d)"`; if `git rev-parse "$VERSION"` succeeds
   (tag already exists — same-day rerun), append `-2`, `-3`, ... until a
   free tag name is found.
5. Rewrite `CHANGELOG.md`: replace the `## Unreleased` line with
   `## Unreleased\n\n## $VERSION - $(date +%Y-%m-%d)`, i.e. insert a fresh
   empty Unreleased section above the newly versioned one (awk, same style
   as the existing `hooks/post-commit` awk block).
6. `git add CHANGELOG.md && git commit -m "chore: release $VERSION"`
   (existing `hooks/post-commit` fires on this commit too — already
   lockfile-guarded against recursion, no change needed).
7. `git tag "$VERSION"`.
8. `git push origin main && git push origin "$VERSION"`.
9. Extract the new version's changelog section (text between its `## ...`
   header and the next `## ` header) into a temp file.
10. `gh release create "$VERSION" --notes-file <tmpfile> --title "$VERSION"`.

### `cron-manager` registration

Add to `/root/cron-manager/jobs.json` via `manage.py add`:

```
manage.py add \
  --id browser-tasks-automation-release \
  --schedule "10 4 * * *" \
  --command "/root/browser-tasks-automation/scripts/cut-release.sh" \
  --description "Daily: cut CalVer release from CHANGELOG.md if new commits exist."
manage.py apply
```

Schedule offset (4:10am) to avoid colliding with the existing
`vps-docs-sync` job (`0 */2 * * *`, fires on the hour) and the unrelated
n8n backup (`0 3 * * *`).

## Auth

New fine-grained GitHub PAT, scoped to
`epipra/Headless-Browser-Ops-by-ePipra` only, Contents: read/write
permission. Stored at `/root/.config/browser-tasks-automation/github_token`
(mode 0600), loaded once via `gh auth login --with-token <
/root/.config/browser-tasks-automation/github_token`. Kept separate from
the pre-existing `vps-docs-sync` token (different project, least
privilege, independent revocation).

## Error handling

- Any step failing (dirty worktree, push rejected, `gh` auth expired,
  network error) causes the script to exit non-zero under
  `set -euo pipefail`.
- `cron-manager`'s `runner.py` already logs full stdout/stderr to
  `logs/browser-tasks-automation-release.log` and sends a Telegram failure
  alert (job `notify` defaults to `true`) — no custom notification code
  needed in the script.
- If commit+tag succeed but push fails, they remain local; the next day's
  run will find the tag already exists remotely-or-not — this is a known,
  accepted gap (low-stakes personal project): manual `git push` fixes it.
  The no-op guard is commit-count-based, not push-state-based, so it will
  not silently swallow a partially-failed release; the script will instead
  fail loudly again on the tag-already-exists-locally case, which is the
  desired signal to investigate.

## Testing

- `python3 /root/cron-manager/manage.py run --id
  browser-tasks-automation-release` — manual trigger, inspect
  `logs/browser-tasks-automation-release.log`.
- Run it twice back-to-back: second run must no-op (no new commit, no
  duplicate tag/release).
- Confirm `CHANGELOG.md` on GitHub shows the new versioned section and
  `Unreleased` is empty again.
- Confirm a GitHub Release appears at
  `https://github.com/epipra/Headless-Browser-Ops-by-ePipra/releases` with
  the correct tag and notes matching the CHANGELOG section.
