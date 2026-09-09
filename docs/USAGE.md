# Command Reference

| Command | Purpose |
|---|---|
| `agent-browser open <url>` | Navigate to a URL |
| `agent-browser snapshot -i` | Get interactive element references (for click/fill targeting) |
| `agent-browser click <ref>` | Click an element by reference |
| `agent-browser fill <ref> "<text>"` | Fill a form field |
| `agent-browser wait <selector\|ms>` | Wait for an element or a fixed duration |
| `agent-browser get text <ref>` | Extract text from an element |
| `agent-browser screenshot <path>` | Save a screenshot |
| `agent-browser close` | End the session and close the browser |
| `agent-browser chat "<instruction>"` | Natural-language driven automation (needs `AI_GATEWAY_API_KEY`) |

## Typical flow

```bash
agent-browser open https://example.com
agent-browser snapshot -i
agent-browser click e2
agent-browser get text e5
agent-browser screenshot result.png
agent-browser close
```

The browser stays open (daemon-backed) between commands until you run `close`,
so you can chain several commands against the same page without reopening it.

## Using a profile (persistent session)

```bash
./scripts/new-profile.sh myprofile
agent-browser open https://example.com --profile ~/.agent-browser-profiles/myprofile
```

## Running isolated parallel tasks

```bash
agent-browser open https://site-a.com --session-name task-a
agent-browser open https://site-b.com --session-name task-b
```
