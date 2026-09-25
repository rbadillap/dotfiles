#!/bin/sh
# install.sh: set up this dotfiles repo on a Mac, starting from a clean install.
#
#   sh -c "$(curl -fsSL https://raw.githubusercontent.com/rbadillap/dotfiles/main/install.sh)"
#
# It shows its plan and asks before changing anything; run with --help for
# options. Every step is skipped when already done, so rerunning is safe.
# Self-contained on purpose: it runs before the repo exists, so it can't use
# lib/. Everything is inside functions and main runs on the last line, so a
# download cut off halfway never executes a partial script.

set -eu

DOTFILES_REPO=${DOTFILES_REPO:-rbadillap/dotfiles}
DOTFILES_REF=${DOTFILES_REF:-main}
DOTFILES_DIR=$HOME/code/$DOTFILES_REPO   # repos live at ~/code/<owner>/<repo>

BREW=/opt/homebrew/bin/brew
BREW_INSTALLER=https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh
# On a clean Mac /usr/bin/git is a stub that opens an install dialog, so the
# Command Line Tools are detected by their real path, never with `command -v git`.
CLT_GIT=/Library/Developer/CommandLineTools/usr/bin/git

usage() {
  cat <<EOF
Usage: install.sh [options]

Sets up $DOTFILES_REPO on this Mac:
  1. Homebrew, which also installs the Xcode Command Line Tools (git, compilers)
  2. The repo, cloned into ~/code/$DOTFILES_REPO
  3. dot.toml with your personal values (restore from 1Password, wizard, or by hand)
  4. bin/dot check, then bin/dot apply if you confirm

Options:
  -n, --dry-run   show the plan and exit without changing anything
  -y, --yes       don't ask: skip the wizard and apply without confirming
      --no-apply  stop after bin/dot check; apply later with bin/dot apply
  -h, --help      show this help

Environment:
  DOTFILES_REPO   GitHub owner/repo to clone (default: rbadillap/dotfiles)
  DOTFILES_REF    branch or tag to clone (default: main)
  NONINTERACTIVE  same as --yes; CI implies it too
  NO_COLOR        disable colors

For agents and CI (no terminal): run with --yes, plus --no-apply to review
bin/dot check before applying. Installing Homebrew needs sudo; without a
terminal that only works if sudo needs no password, otherwise it stops early
and says so. Exit codes: 0 done, 1 failed or stopped, 2 bad usage.
EOF
}

# --- Output -----------------------------------------------------------------

if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  bold=$(printf '\033[1m') dim=$(printf '\033[2m') reset=$(printf '\033[0m')
  blue=$(printf '\033[34m') green=$(printf '\033[32m')
  yellow=$(printf '\033[33m') red=$(printf '\033[31m')
else
  bold= dim= reset= blue= green= yellow= red=
fi

step()  { printf '\n%s==>%s %s%s%s\n' "$blue" "$reset" "$bold" "$*" "$reset"; }
info()  { printf '    %s\n' "$*"; }
warn()  { printf '%sWarning:%s %s\n' "$yellow" "$reset" "$*" >&2; }
abort() { printf '%sError:%s %s\n' "$red" "$reset" "$*" >&2; exit 1; }

# run <command...>: show the command, run it, and name it if it fails.
run() {
  printf '    %s$ %s%s\n' "$dim" "$*" "$reset"
  "$@" || abort "Failed during: $*"
}

# tildify <path>: show paths under $HOME as ~/...
tildify() {
  case $1 in "$HOME"/*) printf '~/%s' "${1#"$HOME"/}" ;; *) printf %s "$1" ;; esac
}

# --- Prompts: read from the terminal, even when the script comes from a pipe -

# ask <question> <default y|n>: succeeds on yes. A single keypress answers,
# no Enter needed: y or n; Enter takes the default; any other key means no.
ask() {
  if [ "$2" = y ]; then hint='[Y/n]'; else hint='[y/N]'; fi
  printf '%s %s ' "$1" "$hint" > /dev/tty
  key=$(getkey)
  case $key in
    '')   key=$2 ;;
    [Yy]) key=y ;;
    *)    key=n ;;
  esac
  echo "$key" > /dev/tty
  [ "$key" = y ]
}

# getkey: read one keypress from the terminal without waiting for Enter.
# Enter comes back empty. The terminal mode is restored even on Ctrl-C.
getkey() {
  tty_state=$(stty -g < /dev/tty)
  trap 'stty "$tty_state" < /dev/tty; exit 130' INT TERM
  stty -icanon -echo min 1 time 0 < /dev/tty
  dd bs=1 count=1 < /dev/tty 2>/dev/null
  stty "$tty_state" < /dev/tty
  trap - INT TERM
}

# choose <question> <key>...: prints the key pressed, one of the given keys.
# Enter picks the first. Other keys are ignored until a valid one is pressed.
choose() {
  question=$1; shift
  printf '%s ' "$question" > /dev/tty
  while :; do
    key=$(getkey)
    [ -n "$key" ] || key=$1
    for option in "$@"; do
      if [ "$key" = "$option" ]; then
        echo "$key" > /dev/tty
        printf %s "$key"
        return 0
      fi
    done
  done
}

# prompt <label> <default>: prints the answer, or the default if left empty.
prompt() {
  printf '    %s [%s]: ' "$1" "$2" > /dev/tty
  read -r reply < /dev/tty || reply=
  printf %s "${reply:-$2}"
}

# --- Steps ------------------------------------------------------------------

parse_args() {
  dry_run=0 yes=0 no_apply=0
  while [ $# -gt 0 ]; do
    case $1 in
      -n|--dry-run) dry_run=1 ;;
      -y|--yes)     yes=1 ;;
      --no-apply)   no_apply=1 ;;
      -h|--help)    usage; exit 0 ;;
      *)            usage >&2; exit 2 ;;
    esac
    shift
  done
  if [ -n "${NONINTERACTIVE:-}" ] || [ -n "${CI:-}" ]; then yes=1; fi
  if [ "$yes" = 1 ]; then interactive=0; else interactive=1; fi
}

preflight() {
  [ "$(uname -s)" = Darwin ] || abort "This installer only supports macOS."
  [ "$(uname -m)" = arm64 ] || abort "Homebrew only supports Apple Silicon Macs; this one is $(uname -m)."
  [ "$(id -u)" != 0 ] || abort "Don't run this as root. Run it as your user; it asks for sudo when needed."
  command -v curl >/dev/null || abort "curl is required."
}

# detect: what's already done, so the plan and the steps can skip it.
detect() {
  have_clt=0;  [ -x "$CLT_GIT" ] && have_clt=1
  have_brew=0; [ -x "$BREW" ] && have_brew=1
  if [ -d "$DOTFILES_DIR/.git" ]; then
    repo_state=git
  elif [ -x "$DOTFILES_DIR/bin/dot" ]; then
    repo_state=local   # repo files present but not a git clone
  elif [ -e "$DOTFILES_DIR" ]; then
    abort "$(tildify "$DOTFILES_DIR") exists but isn't this repo. Move it aside and rerun."
  else
    repo_state=missing
  fi
  have_conf=0; [ -f "$DOTFILES_DIR/dot.toml" ] && have_conf=1
  return 0
}

# item <done 0|1> <name> <why>
item() {
  if [ "$1" = 1 ]; then
    printf '  %s✓%s %-20s %salready done%s\n' "$green" "$reset" "$2" "$dim" "$reset"
  else
    printf '  • %-20s %s\n' "$2" "$3"
  fi
}

plan() {
  step "This script will set up $DOTFILES_REPO on this Mac:"
  item "$have_brew" "Homebrew" "package manager for everything else"
  item "$have_clt" "Command Line Tools" "git and compilers; Homebrew's installer adds them"
  case $repo_state in
    git)     item 0 "Update the repo" "git pull in $(tildify "$DOTFILES_DIR")" ;;
    local)   item 1 "Get the repo" ;;
    missing) item 0 "Clone the repo" "into $(tildify "$DOTFILES_DIR"), where all repos live" ;;
  esac
  item "$have_conf" "dot.toml" "your personal values: restore from 1Password, wizard, or by hand"
  if [ "$no_apply" = 1 ]; then then_apply="then stop (--no-apply)"
  elif [ "$interactive" = 1 ]; then then_apply="then ask before applying"
  else then_apply="then apply without asking (--yes)"; fi
  item 0 "bin/dot check" "show what would change on this Mac, $then_apply"
  if [ "$have_brew" = 0 ]; then
    echo
    info "You'll be asked for your password once: Homebrew needs admin rights"
    info "to create /opt/homebrew and to install the Command Line Tools."
  fi
}

# sudo_start: ask for the password once, and keep sudo alive until we exit.
sudo_start() {
  if ( : < /dev/tty ) 2>/dev/null; then
    sudo -v < /dev/tty || abort "Admin rights are required to install Homebrew."
  else
    sudo -n -v 2>/dev/null ||
      abort "Installing Homebrew needs sudo, and there's no terminal to ask for a password. Run install.sh yourself in a terminal."
  fi
  ( while kill -0 "$$" 2>/dev/null; do sudo -n true; sleep 50; done ) 2>/dev/null &
  sudo_keepalive=$!
}

install_brew() {
  step "Homebrew"
  if [ "$have_brew" = 1 ]; then
    info "Already installed."
  else
    sudo_start
    info "Running Homebrew's official installer; it installs the Command Line Tools first."
    printf '    %s$ NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL %s)"%s\n' "$dim" "$BREW_INSTALLER" "$reset"
    # Non-interactive so there's no second prompt: we already showed the plan and have sudo.
    NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL "$BREW_INSTALLER")" ||
      abort "Homebrew's installer failed. Rerun this script to retry."
  fi
  eval "$("$BREW" shellenv)"
  [ -x "$CLT_GIT" ] ||
    abort "The Command Line Tools are missing. Run 'xcode-select --install', then rerun this script."
}

get_repo() {
  step "Repo"
  case $repo_state in
    git)
      origin=$(git -C "$DOTFILES_DIR" remote get-url origin 2>/dev/null) || origin=
      # The whole URL, not a substring: any host could serve a path ending in the repo.
      case $origin in
        "https://github.com/$DOTFILES_REPO" | "https://github.com/$DOTFILES_REPO.git" | \
        "git@github.com:$DOTFILES_REPO" | "git@github.com:$DOTFILES_REPO.git" | \
        "ssh://git@github.com/$DOTFILES_REPO" | "ssh://git@github.com/$DOTFILES_REPO.git")
          run git -C "$DOTFILES_DIR" pull --ff-only ;;
        *) abort "$(tildify "$DOTFILES_DIR") is a different repo ($origin). Move it aside and rerun." ;;
      esac ;;
    local)
      info "$(tildify "$DOTFILES_DIR") already has the repo files (not a git clone); using them." ;;
    missing)
      run mkdir -p "$(dirname "$DOTFILES_DIR")"
      # HTTPS, not SSH: a clean Mac has no SSH key yet.
      run git clone --branch "$DOTFILES_REF" "https://github.com/$DOTFILES_REPO.git" "$DOTFILES_DIR" ;;
  esac
}

# personal_values: make sure dot.toml exists; fails if the user will create it by hand.
personal_values() {
  step "Personal values"
  if [ -f "$DOTFILES_DIR/dot.toml" ]; then
    info "dot.toml already exists; leaving it as is."
    return 0
  fi
  if [ "$interactive" = 1 ]; then
    info "dot.toml holds your personal values (hostname, git identity, …)."
    case $(choose "    [r] restore from 1Password  [w] wizard  [m] I'll create it myself" r w m) in
      r) if restore_conf; then return 0; fi
         info "Continuing with the wizard instead."
         wizard; return 0 ;;
      w) wizard; return 0 ;;
    esac
  fi
  info "dot.toml holds your personal values. Create it from the template and edit it:"
  echo
  info "  cd $(tildify "$DOTFILES_DIR")"
  info "  cp dot.toml.example dot.toml"
  echo
  info "Then run bin/dot check to see what would change, and bin/dot apply to apply it."
  return 1
}

# restore_conf: download the dot.toml backup from 1Password (the Document
# "dotfiles: dot.toml", saved by `dot conf backup`). Installs 1Password and
# its CLI first, and waits while you sign in. Fails if you give up.
restore_conf() {
  step "Restoring dot.toml from 1Password"
  run brew install --quiet --cask --adopt 1password 1password-cli
  open -a 1Password
  info "In 1Password: sign in, then turn on Settings → Developer →"
  info "Integrate with 1Password CLI. Then come back here."
  while ask "    Ready to restore?" y; do
    if op document get "dotfiles: dot.toml" --out-file "$DOTFILES_DIR/dot.toml" --force >/dev/null 2>&1; then
      # Same record `dot conf backup` keeps (src/lib/op.sh), so check sees it as backed up.
      state=${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles
      mkdir -p "$state"
      shasum -a 256 "$DOTFILES_DIR/dot.toml" | cut -d' ' -f1 > "$state/dotfiles-dot-toml.sha256"
      info "Restored $(tildify "$DOTFILES_DIR/dot.toml")."
      return 0
    fi
    warn "Couldn't read \"dotfiles: dot.toml\" from 1Password: not signed in yet, CLI integration off, or no backup."
  done
  return 1
}

# wizard: ask for each value in dot.toml.example, defaulting to the example's.
# The rest of the example (comments, commented-out tables) is kept.
wizard() {
  conf=$DOTFILES_DIR/dot.toml
  table=
  printf '# Created by install.sh from dot.toml.example.\n' > "$conf.tmp"
  while IFS= read -r line || [ -n "$line" ]; do
    case $line in
      '['*) table=$(printf %s "$line" | sed 's/^\[//; s/\].*//; s/[[:space:]]//g') ;;
      [A-Za-z0-9_-]*=*'"'*)
        key=$(printf %s "$line" | sed 's/[[:space:]]*=.*//')
        value=$(printf %s "$line" | sed 's/^[^"]*"//; s/"[^"]*$//')
        answer=$(prompt "${table:+$table.}$key" "$value" | sed 's/[\\"]/\\&/g')
        line="$key = \"$answer\"" ;;
    esac
    printf '%s\n' "$line" >> "$conf.tmp"
  done < "$DOTFILES_DIR/dot.toml.example"
  mv "$conf.tmp" "$conf"
  info "Saved $(tildify "$conf")."
}

hand_over() {
  cd "$DOTFILES_DIR"
  step "Checking this Mac against config/"
  if bin/dot check; then
    info "Nothing to change."
    return 0
  fi
  if [ "$no_apply" = 1 ]; then
    info "Stopped before applying (--no-apply). Review the above, then run bin/dot apply."
    return 0
  fi
  if [ "$interactive" = 1 ] && ! ask "    Apply these changes now?" n; then
    info "Skipped. Apply them later with bin/dot apply."
    return 0
  fi
  step "Applying"
  bin/dot apply
}

next_steps() {
  step "Done"
  info "Repo:  $(tildify "$DOTFILES_DIR")"
  info "Open a new terminal so Homebrew is on your PATH."
  info "Rerun anytime: cd $(tildify "$DOTFILES_DIR") && bin/dot check"
}

cleanup() {
  status=$?
  [ -n "${sudo_keepalive:-}" ] && kill "$sudo_keepalive" 2>/dev/null
  if [ "$status" != 0 ]; then
    printf '\n%sInstallation stopped.%s Fix the error above and rerun install.sh; finished steps are skipped.\n' "$red" "$reset" >&2
  fi
  exit "$status"
}

main() {
  parse_args "$@"
  preflight
  detect
  plan
  if [ "$dry_run" = 1 ]; then
    echo
    info "Dry run: nothing was changed."
    exit 0
  fi
  if [ "$interactive" = 1 ]; then
    ( : < /dev/tty ) 2>/dev/null ||
      abort "No terminal to ask questions on. Rerun with --yes --no-apply to install and review bin/dot check, or --yes to also apply."
    echo
    ask "Continue?" y || { info "Cancelled; nothing was changed."; exit 0; }
  fi
  if [ "$have_brew" = 0 ] && [ "$interactive" = 0 ] && ! ( : < /dev/tty ) 2>/dev/null && ! sudo -n -v 2>/dev/null; then
    abort "Installing Homebrew needs sudo, and there's no terminal to ask for a password. Run install.sh yourself in a terminal."
  fi
  trap cleanup EXIT
  install_brew
  get_repo
  if personal_values; then hand_over; fi
  next_steps
}

main "$@"
