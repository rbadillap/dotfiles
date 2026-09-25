# Shell settings.

# shell init <zsh>   ~/.zshrc runs `dot init zsh` from one managed block, which
# sets up Homebrew, dot and its completion, and loads config/shell/. Anything
# else in ~/.zshrc is left alone and listed as a note: its line number and
# first word only (cut at "="), since the rest of a line may hold a secret.
shell_init() {
  [ "$1" = zsh ] || { fail "shell init: only 'zsh' is supported, got '$1'"; return; }
  rc=$HOME/.zshrc
  file_managed_block "$rc" 644 "# >>> dotfiles: managed by dot apply shell
eval \"\$(\"$DOT_ROOT/bin/dot\" init zsh)\"
# <<< dotfiles"
  [ -f "$rc" ] || return 0
  foreign=$(awk '/^# >>> dotfiles/ { skip = 1 } !skip && NF && !/^[[:space:]]*#/ { w = $1; sub(/=.*/, "=", w); print "line " NR ": " w " …" } /^# <<< dotfiles/ { skip = 0 }' "$rc")
  [ -n "$foreign" ] || return 0
  # A here-document, not a pipe, so note() runs in this shell and keeps its notes.
  while IFS= read -r line; do note "not from this repo: $line"; done <<NOTES
$foreign
NOTES
}
