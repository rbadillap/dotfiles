# Shell settings.

# shell live <main>   ~/.zshrc, the links into ~ and the gh and vercel shims
# run ~/.local/share/dotfiles/live, a copy of this repo at origin's main
# branch, never the working copy: a branch checked out there runs nowhere.
# dot update creates the copy and moves it to the latest main; check reports
# when it's behind, or when an app changed a file in it.
shell_live() {
  [ "$1" = main ] || { fail "shell live: only 'main' is supported, got '$1'"; return; }
  live_copy
}

# shell init <zsh>   ~/.zshrc runs `dot init zsh` from the live copy, in one
# managed block, which sets up Homebrew, dot and its completion, and loads
# config/shell/; without the live copy it only says so. Anything
# else in ~/.zshrc is left alone and noted by line number only: no part of a
# line is shown, since a line (or a quoted value spanning several) may hold a
# secret.
shell_init() {
  [ "$1" = zsh ] || { fail "shell init: only 'zsh' is supported, got '$1'"; return; }
  live_exists || { fail "shell init: no live copy at ~/.local/share/dotfiles/live; run dot update"; return; }
  rc=$HOME/.zshrc dot_bin=$(shquote "$DOT_LIVE/bin/dot")
  file_managed_block "$rc" 644 "# >>> dotfiles: managed by dot apply shell
if [ -x $dot_bin ]; then eval \"\$($dot_bin init zsh)\"; else echo 'dotfiles: no live copy at ~/.local/share/dotfiles/live; run bin/dot update in the repo' >&2; fi
# <<< dotfiles"
  [ -f "$rc" ] || return 0
  foreign=$(awk '/^# >>> dotfiles/ { skip = 1 } !skip && NF && !/^[[:space:]]*#/ { l = l (l ? ", " : "") NR } /^# <<< dotfiles/ { skip = 0 } END { print l }' "$rc")
  [ -z "$foreign" ] || note "not from this repo: ~/.zshrc line(s) $foreign"
}
