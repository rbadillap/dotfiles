# Homebrew packages. Removing a line leaves the package installed.

# brew formula <name>   a command-line package, e.g. gh
brew_formula() {
  case $1 in
    ''|*[!a-z0-9@._+-]*) fail "brew formula: invalid name '$1'"; return ;;
  esac
  brewpkg formula "$1"
}

# brew cask <name>   an app or prebuilt binary, e.g. 1password
brew_cask() {
  case $1 in
    ''|*[!a-z0-9@._+-]*) fail "brew cask: invalid name '$1'"; return ;;
  esac
  brewpkg cask "$1"
}
