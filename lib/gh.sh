# GitHub account settings via gh(1). Sourced by dot.

# ghx <args>: gh, through 1Password's shell plugin when that's where its token
# lives. May ask for Touch ID.
ghx() {
  # `op plugin inspect` needs a terminal, so detect the plugin by its config file.
  if [ -f "$HOME/.config/op/plugins/gh.json" ]; then op plugin run -- gh "$@"; else gh "$@"; fi
}

# gh_ssh_key <authentication|signing> <public key> <title>
gh_ssh_key() {
  case $1 in signing) endpoint=ssh_signing_keys ;; *) endpoint=keys ;; esac
  if ! list=$(ghx api "user/$endpoint" --jq '.[].key' 2>&1); then
    fail "GitHub $1 keys: can't list them. Does the token allow SSH keys? ($(printf %s "$list" | tail -1))"
    return
  fi
  material=$(printf %s "$2" | awk '{ print $2 }')
  case $list in *"$material"*) return 0 ;; esac

  if [ "$DOT_MODE" = apply ]; then
    keyfile=$(mktemp)
    printf '%s\n' "$2" > "$keyfile"
    ghx ssh-key add "$keyfile" --type "$1" --title "$3" >/dev/null 2>&1 || { rm -f "$keyfile"; fail "gh ssh-key add failed"; return; }
    rm -f "$keyfile"
    DOT_CHANGED=1
  fi
  changed "GitHub $1 key" "missing" "$3"
}
