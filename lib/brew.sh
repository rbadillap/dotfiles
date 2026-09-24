# Packages via Homebrew. Sourced by dot.

# Homebrew may not be on PATH yet in a shell opened before it was installed.
brew_bin() {
  command -v brew 2>/dev/null || { [ -x /opt/homebrew/bin/brew ] && echo /opt/homebrew/bin/brew; }
}

# brewpkg <formula|cask> <name>: installed, or installed on apply.
# Installed packages are listed once per run and cached.
brewpkg() {
  brew=$(brew_bin) || { fail "Homebrew isn't installed; run install.sh first"; return; }
  if [ -z "${DOT_BREW_LIST:-}" ]; then
    DOT_BREW_LIST=$("$brew" list --formula -1 2>/dev/null | sed 's/^/formula /'; "$brew" list --cask -1 2>/dev/null | sed 's/^/cask /')
    DOT_BREW_LIST="$DOT_BREW_LIST
"
  fi
  case $DOT_BREW_LIST in *"$1 $2
"*) return 0 ;; esac

  if [ "$DOT_MODE" = apply ]; then
    # --adopt: an app already installed by hand (same version) becomes managed
    # by Homebrew instead of failing with "already an App".
    adopt=; [ "$1" = cask ] && adopt=--adopt
    if ! out=$(HOMEBREW_NO_ENV_HINTS=1 "$brew" install --quiet "--$1" $adopt "$2" 2>&1 </dev/null); then
      fail "brew install --$1 $2 failed: $(printf %s "$out" | grep -m1 '^Error' || printf %s "$out" | tail -1)"
      return
    fi
    DOT_CHANGED=1
  fi
  changed "brew $1 $2" "not installed" "installed"
}
