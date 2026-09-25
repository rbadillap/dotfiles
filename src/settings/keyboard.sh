# Keyboard settings. Values below the System Settings minimum are allowed.

# keyboard repeat-rate <n>   lower is faster; System Settings goes down to 2
keyboard_repeat_rate() {
  default NSGlobalDomain KeyRepeat -int "$1"
  effect "log out and back in (keyboard repeat)"
}

# keyboard repeat-delay <n>   lower is shorter; System Settings goes down to 15
keyboard_repeat_delay() {
  default NSGlobalDomain InitialKeyRepeat -int "$1"
  effect "log out and back in (keyboard repeat)"
}

# keyboard press-and-hold <true|false>   true: holding a letter shows its
# accents (á, ñ…); false: the letter repeats instead
keyboard_press_and_hold() {
  case $1 in true|false) ;; *) fail "keyboard press-and-hold: expected true or false, got '$1'"; return ;; esac
  default NSGlobalDomain ApplePressAndHoldEnabled -bool "$1"
  effect "quit and reopen apps (press and hold)"
}
