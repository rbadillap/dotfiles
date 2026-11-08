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

# op agent-token <gh> $github.*   an agent, or any process without a person at
# a terminal, runs gh with this token instead of the personal one: agent_token
# under [github] in dot.toml, a 1Password reference (op://vault/item/field)
# to a token limited to the repos agents work on. Kept in
# ~/.local/share/dotfiles/agent-tokens/gh, which the shim reads; if that token
# fails, the command fails, never falling back to the personal one.
op_agent_token() {
  [ "$1" = gh ] || { fail "op agent-token: only gh is supported, got '$1'"; return; }
  file=$HOME/.local/share/dotfiles/agent-tokens/$1
  if ! ref=$(conf_get "$2.agent_token"); then
    note "no agent_token under [$2] in dot.toml: agents use your personal token"
    [ ! -e "$file" ] || note "$(printf %s "$file" | sed "s#^$HOME#~#") still sets one; delete it to stop using it"
    return 0
  fi
  case $ref in
    *[!A-Za-z0-9\ ._/:-]*) fail "op agent-token: $2.agent_token has characters a 1Password reference doesn't, got '$ref'"; return ;;
    op://?*/?*/?*) ;;
    *) fail "op agent-token: $2.agent_token must be op://<vault>/<item>/<field>, got '$ref'"; return ;;
  esac
  file_managed_block "$file" 600 "# >>> $1 agent token: managed by dot apply op
$ref
# <<< $1 agent token"
}
