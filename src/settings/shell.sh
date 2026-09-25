# Shell settings.

# shell init <zsh>   ~/.zshrc runs `dot init zsh` from one managed block, which
# sets up Homebrew, dot and its completion, and loads config/shell/. Anything
# else in ~/.zshrc is left alone and noted by line number only: no part of a
# line is shown, since a line (or a quoted value spanning several) may hold a
# secret.
shell_init() {
  [ "$1" = zsh ] || { fail "shell init: only 'zsh' is supported, got '$1'"; return; }
  rc=$HOME/.zshrc
  file_managed_block "$rc" 644 "# >>> dotfiles: managed by dot apply shell
eval \"\$($(shquote "$DOT_ROOT/bin/dot") init zsh)\"
# <<< dotfiles"
  [ -f "$rc" ] || return 0
  foreign=$(awk '/^# >>> dotfiles/ { skip = 1 } !skip && NF && !/^[[:space:]]*#/ { l = l (l ? ", " : "") NR } /^# <<< dotfiles/ { skip = 0 } END { print l }' "$rc")
  [ -z "$foreign" ] || note "not from this repo: ~/.zshrc line(s) $foreign"
}
