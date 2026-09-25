# Agents

Claude Code (the CLI and the desktop app's Code tab) reads
`~/.claude/settings.json`. Claude Code writes its own settings there, so
dotfiles only adds its hooks to that file and never touches the rest.
`config/claude.conf` declares them; the scripts live in
`config/home/.claude/hooks/` and are linked into `~/.claude/hooks/`.

    dot check claude     # which hooks are missing
    dot apply claude     # add them

A new or changed hook takes effect in the next Claude Code session.

## Hooks

| Hook | Runs | Why |
|------|------|-----|
| `no-links-in-email.sh` | before the Gmail connector's `send_message`, `create_draft` and `update_draft` | blocks an email whose subject or body holds a URL or a domain name |

**`no-links-in-email.sh`.** The claude.ai Gmail connector rewrites every URL
and bare domain it writes into a `google.com/url?q=…` redirect, and that is
what the recipient gets. Email addresses aren't affected. With the hook, the
agent is told to rewrite the text without links, or to hand you the text to
send from Gmail on the web.

## Known issues these hooks work around

Check these before changing a hook; once one is fixed, remove the hook that
works around it (its line in `config/claude.conf`, its script, and its entry
in `~/.claude/settings.json`).

| Issue | Hook | Checked |
|-------|------|---------|
| [anthropics/claude-code#66010](https://github.com/anthropics/claude-code/issues/66010): Gmail connector rewrites URLs into Google redirects (main report) | `no-links-in-email.sh` | 2026-09-25, open |
| [anthropics/claude-code#94247](https://github.com/anthropics/claude-code/issues/94247): the same for bare domains and `htmlBody` | `no-links-in-email.sh` | 2026-09-25, open |
| [anthropics/claude-code#66847](https://github.com/anthropics/claude-code/issues/66847): the same in `create_draft` | `no-links-in-email.sh` | closed as a duplicate of #66010 |
