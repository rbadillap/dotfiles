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
