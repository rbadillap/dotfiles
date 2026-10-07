# GitHub account settings via gh(1). Sourced by dot.

# ghx <args>: gh, through 1Password's shell plugin when that's where its token
# lives. May ask for Touch ID.
ghx() {
  # `op plugin inspect` needs a terminal, so detect the plugin by its config file.
  if [ -f "$HOME/.config/op/plugins/gh.json" ]; then op plugin run -- gh "$@"; else gh "$@"; fi
}

# gh_ssh_key <user> <authentication|signing> <public key> <title>
# check reads GitHub's public key lists, so it needs no token and no Touch ID;
# only apply goes through gh (and 1Password).
gh_ssh_key() {
  user=$1; shift
  case $1 in
    signing) url=https://api.github.com/users/$user/ssh_signing_keys ;;
    *)       url=https://github.com/$user.keys ;;
  esac
  if ! list=$(curl -fsS "$url" 2>&1); then
    fail "GitHub $1 keys: can't read $url ($list)"
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

# gh_ext <owner/gh-name>: a gh extension is installed, or installed on apply.
# check reads gh's extensions folder, so it needs no token and no Touch ID
# (gh extension list itself wants a login). Install only; upgrades are
# gh extension upgrade's.
gh_ext() {
  dir=${XDG_DATA_HOME:-$HOME/.local/share}/gh/extensions/${1#*/}
  [ -d "$dir" ] && return 0
  if [ "$DOT_MODE" = apply ]; then
    if ! out=$(ghx extension install "$1" 2>&1); then
      msg="gh extension install $1 failed: $(printf %s "$out" | grep -v '^$' | tail -1)"
      # The usual cause through the shell plugin: op can't reach the app.
      [ -f "$HOME/.config/op/plugins/gh.json" ] &&
        msg="$msg (if 1Password couldn't connect: open and unlock the app, with Settings › Developer › Integrate with 1Password CLI on)"
      fail "$msg"
      return
    fi
    DOT_CHANGED=1
  fi
  changed "gh extension $1" "not installed" "installed"
}
