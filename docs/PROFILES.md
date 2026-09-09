# Profiles

A profile is a persistent Chrome user-data directory. Anything that gets
logged into inside a profile (cookies, session tokens) stays there for future
runs, so you don't have to log in every time.

## Creating a profile

```bash
./scripts/new-profile.sh <name>
```

This creates `~/.agent-browser-profiles/<name>` and prints the exact command
to use it.

## Logging into an account inside a profile

Do NOT script username/password entry through `agent-browser fill`. Two
reasons:

1. Most major platforms (Google, Microsoft, Meta, etc.) actively detect and
   block automated/headless login attempts, so it will likely just fail.
2. Typed credentials end up in shell history and command output, which is
   avoidable.

The reliable pattern is a one-time **manual** login, done through a real
graphical browser window pointed at the exact same profile directory. After
that one-time login, all future `agent-browser` calls using `--profile
<same-path>` will reuse the saved session automatically, headless, with no
credentials involved.

### On a headless server (VPS)

Run a temporary lightweight VNC session, open real Chrome (not agent-browser)
pointed at the profile directory, log in by hand through the actual UI, close
Chrome, then tear the VNC session down. From then on `agent-browser` reuses
that same profile headlessly.

### On a local machine

If you're already logged into the account in your normal Chrome profile, you
can point `--profile` directly at that existing Chrome user-data directory
instead of creating a new one, so no fresh login is needed at all.

See `docs/SECURITY.md` for why profile folders should never be committed to
git or shared.
