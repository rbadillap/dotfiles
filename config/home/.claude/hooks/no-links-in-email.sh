#!/bin/sh
# Claude Code PreToolUse hook: blocks a Gmail connector send or draft whose
# subject or body holds a URL or a domain name.
#
# The claude.ai Gmail connector rewrites every URL and bare domain it writes
# (send_message, create_draft, update_draft) into a google.com/url?q=… redirect,
# and that is what the recipient gets. Open bugs, checked 2026-09-25:
#   https://github.com/anthropics/claude-code/issues/66010  (main report)
#   https://github.com/anthropics/claude-code/issues/94247
#   https://github.com/anthropics/claude-code/issues/66847  (closed as a duplicate)
# Agents: check those issues. Once the rewrite is fixed, remove the
# `claude hook` line in config/claude.conf, this file, and its entry in
# ~/.claude/settings.json.
#
# Reads the hook's JSON on stdin. Exit 2 blocks the call; stderr tells Claude why.
input=$(cat)

# Only mail tools: send_message and create_draft take `to`, update_draft a draftId.
# Other connectors' send_message (Slack…) pass through.
printf '%s' "$input" | /usr/bin/jq -e '.tool_input | has("to") or has("draftId")' >/dev/null 2>&1 || exit 0

text=$(printf '%s' "$input" | /usr/bin/jq -r '.tool_input | [.subject, .body, .htmlBody] | map(select(. != null)) | join("\n")')

# Email addresses aren't rewritten (they become mailto:), so they don't count.
if printf '%s\n' "$text" | sed -E 's/[[:alnum:]._%+-]+@[[:alnum:].-]+//g' |
  grep -Eiq '(https?://|www\.|[[:alnum:]-]+\.[[:alpha:]]{2,}([/?#:]|[[:space:][:punct:]]|$))'; then
  cat >&2 <<'MSG'
Blocked: this email contains a URL or a domain name. The Gmail connector
rewrites every one into a google.com/url?q=… redirect, and the recipient gets
that (https://github.com/anthropics/claude-code/issues/66010). Rewrite the text
without any URL or domain (not even a bare "example.com"), or give the user the
text to send from Gmail on the web.
MSG
  exit 2
fi
exit 0
