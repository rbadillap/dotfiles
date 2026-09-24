# GitHub account settings. Needs gh logged in; see docs/auth/github.md.

# github ssh-key <title>   add this 1Password SSH key (by item title) to GitHub,
# for authentication and for signing. The key's title on GitHub is the hostname.
github_ssh_key() {
  key=$(ssh_pubkey "$*")
  [ -n "$key" ] || { fail "github ssh-key: 1Password's SSH agent has no key titled '$*'"; return; }
  title="$(scutil --get LocalHostName 2>/dev/null) (1Password)"
  gh_ssh_key authentication "$key" "$title"
  gh_ssh_key signing "$key" "$title"
}
