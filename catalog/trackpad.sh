# Trackpad settings. Built-in and Bluetooth trackpads keep separate keys;
# these set both.

# trackpad speed <0.0-3.0>
trackpad_speed() {
  default NSGlobalDomain com.apple.trackpad.scaling -float "$1"
}

# trackpad tap-to-click <true|false>
trackpad_tap_to_click() {
  case $1 in
    true)  tap=1 ;;
    false) tap=0 ;;
    *) fail "trackpad tap-to-click: expected true or false, got '$1'"; return ;;
  esac
  default com.apple.AppleMultitouchTrackpad Clicking -bool "$1"
  default com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool "$1"
  default -currentHost NSGlobalDomain com.apple.mouse.tapBehavior -int "$tap"
  effect "log out and back in (trackpad)"
}

# trackpad three-finger-drag <true|false>
# Like System Settings, enabling it moves three-finger swipes to four fingers.
trackpad_three_finger_drag() {
  case $1 in
    true)  swipe=0 ;;
    false) swipe=2 ;;
    *) fail "trackpad three-finger-drag: expected true or false, got '$1'"; return ;;
  esac
  for domain in com.apple.AppleMultitouchTrackpad com.apple.driver.AppleBluetoothMultitouch.trackpad; do
    default "$domain" TrackpadThreeFingerDrag -bool "$1"
    default "$domain" TrackpadThreeFingerHorizSwipeGesture -int "$swipe"
    default "$domain" TrackpadThreeFingerVertSwipeGesture -int "$swipe"
  done
  effect "log out and back in (trackpad)"
}
