# Homebrew packages. Removing a line leaves the package installed.

# brew formula <name>   a command-line package, e.g. gh, or one from a tap:
# owner/tap/name (add the tap with brew tap first)
brew_formula() {
  brew_name "$1" || { fail "brew formula: invalid name '$1'"; return; }
  brewpkg formula "$1"
}

# brew cask <name>   an app, font or prebuilt binary, e.g. 1password
brew_cask() {
  brew_name "$1" || { fail "brew cask: invalid name '$1'"; return; }
  brewpkg cask "$1"
}

# brew tap <owner/repo>   a third-party package source; tapping means trusting
# that repository, so each tap is declared here explicitly
brew_tap() {
  case $1 in
    */*/*|/*|*/|*[!a-z0-9._/-]*) fail "brew tap: expected owner/repo, got '$1'"; return ;;
    */*) ;;
    *) fail "brew tap: expected owner/repo, got '$1'"; return ;;
  esac
  brewtap "$1"
}
