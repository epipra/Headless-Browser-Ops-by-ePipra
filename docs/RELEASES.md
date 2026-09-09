# Automated Releases

This repo cuts its own dated GitHub Releases with no manual steps beyond a
one-time setup. Two mechanisms work together:

1. **Every commit** — `hooks/post-commit` (enabled by `install.sh` via
   `git config core.hooksPath hooks`) appends a line to `CHANGELOG.md`
   under `## Unreleased`.
2. **Every day at 04:10** — a cron job runs `scripts/cut-release.sh`. If
   there are new commits since the last release tag, it turns the current
   `## Unreleased` section into a dated `## vYYYY.MM.DD` release, tags it,
   pushes, and publishes a GitHub Release with that section as the release
   notes. If nothing changed since the last release, it does nothing —
   never publishes an empty release.

You don't need to do anything for #1 (already on if you ran `install.sh`).
#2 needs a one-time setup below.

## One-time setup

### 1. Create a GitHub token

Go to <https://github.com/settings/personal-access-tokens/new> and create a
**fine-grained** personal access token:

- Repository access: only this repo (`Headless-Browser-Ops-by-ePipra`)
- Permissions: **Contents: Read and write** (nothing else needed)

Fine-grained + repo-scoped means this token can't touch anything else on
the account, and can be revoked independently of any other token you use.

### 2. Save it where the cron job can read it

```bash
mkdir -p /root/.config/browser-tasks-automation
# paste the token when prompted; nothing is echoed or saved to shell history
read -s TOKEN && printf '%s' "$TOKEN" > /root/.config/browser-tasks-automation/github_token && unset TOKEN
chmod 600 /root/.config/browser-tasks-automation/github_token
```

The script reads this file directly and exports it as `GITHUB_TOKEN` for
`gh` at runtime — it does not depend on `gh auth login` or any shell
profile, so it works the same under cron's minimal environment as it does
run by hand.

### 3. Register the cron job (already done if you're working from this
repo's own setup, but for a fresh clone / another machine)

```bash
python3 /root/cron-manager/manage.py add \
  --id browser-tasks-automation-release \
  --schedule "10 4 * * *" \
  --command "/root/browser-tasks-automation/scripts/cut-release.sh" \
  --description "Daily: cut CalVer release from CHANGELOG.md if new commits exist."
python3 /root/cron-manager/manage.py apply
```

(This VPS uses `/root/cron-manager` as the single place that touches root's
crontab — see that repo's own README before hand-editing `crontab -e`
instead.)

## Using it

Nothing to run day-to-day — commit normally, the changelog and releases
take care of themselves. Two manual entry points if you need them:

**Trigger a release right now** (e.g. to verify setup, or ship immediately
instead of waiting for 04:10):

```bash
python3 /root/cron-manager/manage.py run --id browser-tasks-automation-release
```

**Check whether it's working**, without waiting for cron:

```bash
tail -40 /root/cron-manager/logs/browser-tasks-automation-release.log
tail -5  /root/cron-manager/logs/browser-tasks-automation-release.cron.log
```

A successful run also sends a Telegram notification (handled by
`cron-manager`'s runner, not by this script).

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Log says `Missing /root/.config/browser-tasks-automation/github_token` | One-time setup step 2 was never done | Follow step 2 above |
| `gh release create` fails with `401`/`403` | Token expired, revoked, or missing Contents:write | Generate a new fine-grained token (step 1), overwrite the token file |
| `git push` fails with a non-fast-forward error | Something else pushed to `main` between the changelog rewrite and the push (e.g. you pushed manually at the same moment) | Safe to ignore — rerun the job with `manage.py run --id ...`; the commit/tag are already local, only the push needs retrying (`git push origin main --tags` by hand also works) |
| Log says `No new commits since vX. Nothing to release.` | Working as intended | Nothing to fix — this is the no-op path |
| Same-day rerun creates `v2026.09.09-2` instead of failing | Intentional collision handling — a tag already exists for today | Nothing to fix |

## Security notes

- The token file is a credential — same rules as anything in
  `docs/SECURITY.md`: never commit it, never paste it into chat, never
  share it outside this machine. It already lives outside the repo
  (`/root/.config/...`, not `.env`) so a normal `git add -A` can't catch it.
  `chmod 600` restricts it to root.
- Scope the token to this one repo only. Don't reuse an account-wide token
  meant for other tools (e.g. an MCP connector's `GITHUB_TOKEN`) — if that
  token is ever rotated or revoked for unrelated reasons, this pipeline
  would break too, and a compromise of this automation would then also
  expose whatever else that shared token could touch.
