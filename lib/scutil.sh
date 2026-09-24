# Computer names via scutil(8). Needs sudo. Sourced by dot.

# scutil_name <ComputerName|HostName|LocalHostName> <value>   (needs sudo)
scutil_name() {
  have=$(scutil --get "$1" 2>/dev/null) || have='(unset)'
  [ "$have" = "$2" ] && return 0

  if [ "$DOT_MODE" = apply ]; then
    sudo scutil --set "$1" "$2"
    DOT_CHANGED=1
  fi
  changed "$1" "$have" "$2" sudo
}
