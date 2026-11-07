# 1Password shell plugins: CLIs such as gh get their tokens from 1Password
# (docs/04-your-projects/03-accounts/).

# op shim <gh|vercel>   every process that runs this CLI (a script, an agent,
# another tool) gets its token from 1Password's shell plugin, as an
# interactive shell does: ~/.local/share/dotfiles/shims/<cli>, first on PATH
# (config/shell/op.zsh), is a link to src/shims/op-plugin. Without the plugin
# (op plugin init <cli>), the real CLI runs unchanged.
op_shim() {
  case $1 in gh|vercel) ;; *) fail "op shim: supported CLIs are gh and vercel, got '$1'"; return ;; esac
  link "src/shims/op-plugin" "$HOME/.local/share/dotfiles/shims/$1"
  [ -f "$HOME/.config/op/plugins/$1.json" ] || note "no 1Password plugin for $1 yet: op plugin init $1"
  # Line numbers only: ~/.zshrc is the user's file.
  lines=$(grep -n 'op/plugins\.sh' "$HOME/.zshrc" 2>/dev/null | cut -d: -f1 | paste -sd, - | sed 's/,/, /g')
  [ -z "$lines" ] || note "~/.zshrc line(s) $lines load ~/.config/op/plugins.sh, whose $1 function is a second path the shim makes unneeded: delete them"
}
