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
# a terminal, runs gh with an agent token instead of the personal one, with no
# approval prompt. A fine-grained GitHub token has a single owner (a user or an
# organization), so there is one per owner: under [github.agent_tokens] in
# dot.toml, <owner> = "op://Agents/<item>/<field>", plus agent_token under
# [github] for any other owner or no repo at all. gh uses the token of the
# owner it targets: -R/--repo, GH_REPO, the repo the command names, or the
# current folder's git remote. A 1Password service account that can only read
# the Agents vault fetches it; its credential is in the macOS keychain (service
# dotfiles-op-agents, account $USER), stored by you. The references are kept in
# ~/.local/share/dotfiles/agent-tokens/gh, which the shim reads; if anything
# fails, the command fails, never falling back to the personal token.
op_agent_token() {
  [ "$1" = gh ] || { fail "op agent-token: only gh is supported, got '$1'"; return; }
  file=$HOME/.local/share/dotfiles/agent-tokens/$1
  ref=$(conf_get "$2.agent_token") || ref=
  owners=$(conf_keys "$2.agent_tokens")
  if [ -z "$ref$owners" ]; then
    note "no agent_token under [$2] or [$2.agent_tokens] in dot.toml: agents use your personal token"
    [ ! -e "$file" ] || note "$(printf %s "$file" | sed "s#^$HOME#~#") still sets one; delete it to stop using it"
    return 0
  fi
  lines=
  if [ -n "$ref" ]; then
    op_agent_ref "$2.agent_token" "$ref" || return 0
    lines=$ref
  fi
  seen=" "
  for owner in $owners; do
    case $owner in
      *[!A-Za-z0-9-]*|-*|*-) fail "op agent-token: '$owner' under [$2.agent_tokens] isn't a GitHub user or organization name"; return ;;
    esac
    [ ${#owner} -le 39 ] || { fail "op agent-token: '$owner' under [$2.agent_tokens] is longer than a GitHub name can be"; return; }
    lower=$(printf %s "$owner" | tr '[:upper:]' '[:lower:]')
    case $seen in *" $lower "*) fail "op agent-token: '$owner' appears twice under [$2.agent_tokens] (names ignore case)"; return ;; esac
    seen="$seen$lower "
    oref=$(conf_get "$2.agent_tokens.$owner")
    op_agent_ref "$2.agent_tokens.$owner" "$oref" || return 0
    lines="${lines:+$lines
}$lower $oref"
  done
  [ -n "$ref" ] || note "no agent_token under [$2]: gh fails for agents on owners not under [$2.agent_tokens]"
  file_managed_block "$file" 600 "# >>> $1 agent token: managed by dot apply op
$lines
# <<< $1 agent token"
  # Attributes only, never the secret: no prompt, no Touch ID.
  /usr/bin/security find-generic-password -s dotfiles-op-agents -a "${USER:-$(id -un)}" >/dev/null 2>&1 ||
    fail "op agent-token: no service account credential in the keychain; store it with: security add-generic-password -s dotfiles-op-agents -a \"\$USER\" -w (it asks for the value)"
}
