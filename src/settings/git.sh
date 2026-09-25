# Git settings. Identity comes from dot.toml; see config/git.conf.

# git name <name>   author name on commits; may contain spaces
git_name() {
  [ -n "$*" ] || { fail "git name: empty"; return; }
  gitconfig user.name "$*"
}

# git email <email>
git_email() {
  case $1 in
    ?*@?*.?*) gitconfig user.email "$1" ;;
    *) fail "git email: not an email address: '$1'" ;;
  esac
}

# git signing-key <title>   sign every commit and tag with this 1Password SSH
# key (by item title). Signing asks for Touch ID. Also lets git verify
# signatures locally (git log --show-signature).
git_signing_key() {
  key=$(ssh_pubkey "$*")
  [ -n "$key" ] || { fail "git signing-key: 1Password's SSH agent has no key titled '$*'"; return; }
  email=$(git config --global user.email) || { fail "git signing-key: set 'git email' first"; return; }
  gitconfig gpg.format ssh
  gitconfig gpg.ssh.program /Applications/1Password.app/Contents/MacOS/op-ssh-sign
  gitconfig user.signingkey "$key"
  gitconfig commit.gpgsign true
  gitconfig tag.gpgsign true
  gitconfig gpg.ssh.allowedSignersFile "$HOME/.config/git/allowed_signers"
  file_block "$HOME/.config/git/allowed_signers" 644 "$email $key"
}

# git identity <dir> <name> <email>   commits in repos under <dir> use this
# name and email instead of the global ones (git's includeIf). <dir> may start
# with ~. Signing keeps the global key; the email is added to allowed_signers
# so git can verify those commits locally.
git_identity() {
  [ $# -eq 3 ] || { fail "git identity: expected <dir> <name> <email>"; return; }
  case $1 in "~"/*) dir=$HOME/${1#"~/"} ;; /*) dir=$1 ;; *) fail "git identity: <dir> must be absolute or start with ~/"; return ;; esac
  case $3 in ?*@?*.?*) ;; *) fail "git identity: not an email address: '$3'"; return ;; esac
  dir=${dir%/}/
  file=$HOME/.config/git/identities/$(printf %s "${dir#"$HOME"/}" | tr -c 'A-Za-z0-9\n' - | sed 's/-*$//')
  # Different folders can map to the same file name (company-a, company_a):
  # refuse rather than let one identity overwrite the other's file.
  other=$(git config --global --name-only --get-regexp '^includeif\.gitdir:.*\.path$' 2>/dev/null |
    while IFS= read -r key; do
      [ "$key" = "includeif.gitdir:$dir.path" ] && continue
      [ "$(git config --global --get "$key")" = "$file" ] && printf '%s' "$key"
    done) || true
  other=${other#includeif.gitdir:}
  [ -z "$other" ] || { fail "git identity: $1 would share $(printf %s "$file" | sed "s#^$HOME#~#") with ${other%.path}; rename one of the folders"; return; }
  gitconfig -f "$file" user.name "$2"
  gitconfig -f "$file" user.email "$3"
  gitconfig "includeIf.gitdir:$dir.path" "$file"
  key=$(git config --global --get user.signingkey 2>/dev/null) || return 0
  file_block "$HOME/.config/git/allowed_signers" 644 "$3 $key"
}

# git identities <table>   one `git identity` per table under <table> in
# dot.toml, each with dir, name and email: $git.identity.* reads
# [git.identity.<label>] tables. None is fine.
git_identities() {
  [ $# -eq 1 ] || { fail "git identities: expected a table, such as \$git.identity.*"; return; }
  [ -n "$(conf_tables "$1")" ] || { note "no [$1.*] tables in dot.toml"; return 0; }
  for id in $(conf_tables "$1"); do
    dir=$(conf_get "$1.$id.dir") && name=$(conf_get "$1.$id.name") && email=$(conf_get "$1.$id.email") ||
      { fail "git identities: [$1.$id] needs dir, name and email"; continue; }
    git_identity "$dir" "$name" "$email"
  done
}
