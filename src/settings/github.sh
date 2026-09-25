# GitHub account settings. apply needs gh logged in (docs/04-your-projects/03-accounts/github.mdx).

# github ssh-key <user> <title>   add this 1Password SSH key (by item title) to
# <user>'s GitHub account, for authentication and for signing. The key's title
# on GitHub is the hostname. check needs no Touch ID; apply uses gh.
github_ssh_key() {
  [ $# -ge 2 ] || { fail "github ssh-key: expected <user> <title>"; return; }
  user=$1; shift
  key=$(ssh_pubkey "$*")
  [ -n "$key" ] || { fail "github ssh-key: 1Password's SSH agent has no key titled '$*'"; return; }
  title="$(scutil --get LocalHostName 2>/dev/null) (1Password)"
  gh_ssh_key "$user" authentication "$key" "$title"
  gh_ssh_key "$user" signing "$key" "$title"
}
