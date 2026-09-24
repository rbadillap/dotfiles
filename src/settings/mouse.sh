# Mouse settings.

# mouse speed <0.0-3.0>
mouse_speed() {
  default NSGlobalDomain com.apple.mouse.scaling -float "$1"
}

# mouse secondary-click <right|left|off>
mouse_secondary_click() {
  case $1 in
    right) mode=TwoButton ;;
    left)  mode=TwoButtonSwapped ;;
    off)   mode=OneButton ;;
    *) fail "mouse secondary-click: expected right, left or off, got '$1'"; return ;;
  esac
  default com.apple.AppleMultitouchMouse MouseButtonMode -string "$mode"
  default com.apple.driver.AppleBluetoothMultitouch.mouse MouseButtonMode -string "$mode"
}

# mouse natural-scrolling <true|false>
# macOS stores one value for mouse and trackpad; this changes both.
mouse_natural_scrolling() {
  default NSGlobalDomain com.apple.swipescrolldirection -bool "$1"
}
