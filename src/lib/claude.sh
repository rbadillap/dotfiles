# Claude Code's settings (~/.claude/settings.json). Sourced by dot.
# Claude Code writes its own keys there too, so this only adds entries and
# never rewrites or removes anything else in the file.

# claude_hook_entry <event> <matcher> <command>: ~/.claude/settings.json runs
# <command> for <event> on tools matching <matcher>. apply adds the entry when
# it's missing (creating the file if needed).
claude_hook_entry() {
  f=$HOME/.claude/settings.json
  if [ -f "$f" ] && /usr/bin/jq -e --arg e "$1" --arg m "$2" --arg c "$3" \
    '(.hooks[$e] // []) | any(.matcher == $m and any(.hooks[]?; .type == "command" and .command == $c))' \
    "$f" >/dev/null 2>&1; then
    return 0
  fi
  if [ "$DOT_MODE" = apply ]; then
    mkdir -p "$(dirname "$f")"
    [ -f "$f" ] || printf '{}\n' > "$f"
    out=$(/usr/bin/jq --arg e "$1" --arg m "$2" --arg c "$3" \
      '.hooks[$e] = ((.hooks[$e] // []) + [{matcher: $m, hooks: [{type: "command", command: $c}]}])' "$f") ||
      { fail "~/.claude/settings.json isn't valid JSON; fix it by hand"; return 0; }
    printf '%s\n' "$out" > "$f"   # rewrite in place, keeping the file's owner and links
    DOT_CHANGED=1
  fi
  changed "~/.claude/settings.json hooks.$1" "missing" "$2 → $3"
}
