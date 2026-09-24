# Git settings. Identity comes from dot.conf; see config/git.sh.

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
