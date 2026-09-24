# Shell settings.

# shell init <zsh>   ~/.zshrc loads this repo's shell/init.zsh, through one
# managed block. Anything else in ~/.zshrc is left alone and listed as a note,
# so you can decide whether it belongs in shell/.
shell_init() {
  [ "$1" = zsh ] || { fail "shell init: only 'zsh' is supported, got '$1'"; return; }
  rc=$HOME/.zshrc
  file_block "$rc" 644 "# >>> dotfiles: managed by ./dot apply shell
source \"$DOT_ROOT/shell/init.zsh\"
# <<< dotfiles"
  [ -f "$rc" ] || return 0
  foreign=$(awk '/^# >>> dotfiles/ { skip = 1 } !skip && NF && !/^[[:space:]]*#/ { print } /^# <<< dotfiles/ { skip = 0 }' "$rc")
  [ -n "$foreign" ] || return 0
  # A here-document, not a pipe, so note() runs in this shell and keeps its notes.
  while IFS= read -r line; do note "not from this repo: $line"; done <<EOF
$foreign
EOF
}
