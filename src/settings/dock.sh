# Dock settings.

# dock visibility <always|autohide|hidden>
# hidden: autohide with a very long delay, so it never appears on hover.
dock_visibility() {
  case $1 in
    always)   default com.apple.dock autohide -bool false
              default_unset com.apple.dock autohide-delay ;;
    autohide) default com.apple.dock autohide -bool true
              default_unset com.apple.dock autohide-delay ;;
    hidden)   default com.apple.dock autohide -bool true
              default com.apple.dock autohide-delay -float 1000 ;;
    *) fail "dock visibility: expected always, autohide or hidden, got '$1'"; return ;;
  esac
  restart Dock
}
