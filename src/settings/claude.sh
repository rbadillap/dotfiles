# Claude Code: the CLI and the desktop app's Code tab, which read the same
# ~/.claude/settings.json.

# claude hook <event> <matcher> <script>   ~/.claude/hooks/<script> is a link to
# this repo's config/home/.claude/hooks/<script>, and ~/.claude/settings.json
# runs it for <event> on tools matching <matcher>. Nothing else in the file is
# touched.
claude_hook() {
  [ $# -eq 3 ] || { fail "claude hook: expected <event> <matcher> <script>"; return; }
  case $3 in */* | '') fail "claude hook: <script> is a file name in config/home/.claude/hooks/"; return ;; esac
  link "config/home/.claude/hooks/$3" "$HOME/.claude/hooks/$3"
  # $HOME stays literal: the hook's shell expands it, so the entry fits any Mac.
  claude_hook_entry "$1" "$2" "\"\$HOME\"/.claude/hooks/$3"
}
