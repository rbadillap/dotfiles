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
