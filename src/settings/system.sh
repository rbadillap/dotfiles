# System settings.

# system hostname <name>   letters, digits and hyphens; sets all three macOS names
system_hostname() {
  case $1 in
    ''|-*|*[!A-Za-z0-9-]*) fail "system hostname: use letters, digits and hyphens, got '$1'"; return ;;
  esac
  scutil_name ComputerName "$1"
  scutil_name HostName "$1"
  scutil_name LocalHostName "$1"
}

# system font-smoothing <on|off>   on is macOS's default; off draws thinner text, sharpest on Retina
system_font_smoothing() {
  case $1 in
    on)  default_unset -currentHost NSGlobalDomain AppleFontSmoothing ;;
    off) default -currentHost NSGlobalDomain AppleFontSmoothing -int 0 ;;
    *) fail "system font-smoothing: expected on or off, got '$1'"; return ;;
  esac
  effect "log out and back in (font smoothing)"
}
