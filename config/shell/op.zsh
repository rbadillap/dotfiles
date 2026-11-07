# 1Password shell plugins: gh and vercel get their tokens from 1Password. The
# shims from `op shim` (config/shell.conf) come first on PATH, so every
# process finds them; `op plugin init` also writes ~/.config/op/plugins.sh,
# which isn't loaded: its functions would only reach this shell.
[[ -d ~/.local/share/dotfiles/shims ]] && path=(~/.local/share/dotfiles/shims $path)
