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
