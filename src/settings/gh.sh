# GitHub CLI extensions. apply needs gh logged in (docs/04-your-projects/03-accounts/github.mdx).

# gh extension <owner/gh-name>   install this gh extension, e.g. github/gh-stack.
# check needs no Touch ID; apply uses gh. Upgrade with gh extension upgrade.
gh_extension() {
  [ $# -eq 1 ] || { fail "gh extension: expected <owner/gh-name>"; return; }
  case $1 in
    */gh-*) case $1 in */*/*|*[!A-Za-z0-9._/-]*|.*|-*) ;; *) gh_ext "$1"; return ;; esac ;;
  esac
  fail "gh extension: '$1' isn't owner/gh-name"
}
