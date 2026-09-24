# Packages via Homebrew. Sourced by dot.

# Homebrew may not be on PATH yet in a shell opened before it was installed.
brew_bin() {
  command -v brew 2>/dev/null || { [ -x /opt/homebrew/bin/brew ] && echo /opt/homebrew/bin/brew; }
}

# brew_name <name>: true for a package name, optionally from a tap
# (owner/tap/name).
brew_name() {
  case $1 in
    ''|/*|*/|*//*|*[!a-z0-9@._+/-]*) return 1 ;;
    .*|-*|*/.*|*/-*) return 1 ;;   # no path segments like .. or flags
    */*/*/*) return 1 ;;
    */*) case $1 in */*/*) return 0 ;; *) return 1 ;; esac ;;
  esac
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
  # brew list shows a tap's formulae by their short name (dmno-dev/tap/varlock → varlock).
  case $DOT_BREW_LIST in *"$1 ${2##*/}
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

# brewtap <owner/repo>: a third-party Homebrew tap is added, so its formulae
# and casks can be installed. Tapping means trusting that repository's code.
brewtap() {
  brew=$(brew_bin) || { fail "Homebrew isn't installed; run install.sh first"; return; }
  "$brew" tap 2>/dev/null | grep -qx "$1" && return 0
  if [ "$DOT_MODE" = apply ]; then
    out=$(HOMEBREW_NO_ENV_HINTS=1 "$brew" tap "$1" 2>&1 </dev/null) || { fail "brew tap $1 failed: $(printf %s "$out" | tail -1)"; return; }
    DOT_CHANGED=1
  fi
  changed "brew tap $1" "not tapped" "tapped"
}

# explain_brew_formula <name>, explain_brew_cask <name>: what the package is,
# for dot explain. Reads Homebrew's local metadata; changes nothing.
explain_brew_formula() { brew_explain formula "$1"; }
explain_brew_cask() { brew_explain cask "$1"; }
brew_explain() {
  brew=$(brew_bin) || return 0
  [ -x /usr/bin/jq ] || return 0
  HOMEBREW_NO_AUTO_UPDATE=1 "$brew" info --json=v2 "--$1" "$2" 2>/dev/null | /usr/bin/jq -r '
    (.formulae[0] // empty | [.name, .desc, .homepage, .versions.stable, ([.installed[].version] | first)]),
    (.casks[0] // empty | [.token, .desc, .homepage, .version, .installed])
    | "\(.[0]): \(.[1] // "no description")", "\(.[2])",
      "version \(.[3])" + (if .[4] then ", installed \(.[4])" else ", not installed" end)'
}
