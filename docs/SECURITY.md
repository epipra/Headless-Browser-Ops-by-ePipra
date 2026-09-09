# Security Notes

## Domain allowlisting

Set `AGENT_BROWSER_ALLOWED_DOMAINS` before running any unattended or
scheduled automation. Without it, a bad selector, a redirect, or an
unexpected link on a page could send the automation somewhere you didn't
intend. Once set, any navigation outside the list is blocked automatically.

## Profile folders contain live session data

Everything under `~/.agent-browser-profiles/` (cookies, local storage,
login sessions) is equivalent to being logged into those accounts. This
repo's `.gitignore` excludes the `profiles/` folder for that reason.

- Never commit a profile folder to git, even a private repo.
- Never share a profile folder over chat, email, or any unencrypted channel.
- Treat it the same way you'd treat a saved password file.

## Credential entry

Never script raw username/password entry into a login form (see
`docs/PROFILES.md` for the correct pattern: one-time manual login, then
reuse the saved session). This avoids both the practical problem (most
platforms block automated logins) and the safety problem (credentials
ending up in shell history or logs).

## Screenshots and logs

Screenshots and command output may capture page content, including anything
visible on an authenticated page. Don't paste screenshots from an
authenticated session into chat tools or share them outside your own
records.
