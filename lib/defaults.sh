# macOS preferences via defaults(1). Sourced by dot.

# default [-currentHost] <domain> <key> <-bool|-int|-float|-string> <value>
default() {
  host=
  [ "$1" = -currentHost ] && { host=-currentHost; shift; }
  domain=$1 key=$2 type=$3 want=$4
  have=$(defaults $host read "$domain" "$key" 2>/dev/null) || have='(unset)'

  case $type in
    -bool) case $want in true|yes|1) want=1 ;; *) want=0 ;; esac ;;
  esac
  if [ "$type" = -float ] && [ "$have" != '(unset)' ]; then
    same=$(awk -v a="$have" -v b="$want" 'BEGIN { print (a + 0 == b + 0) }')
  else
    [ "$have" = "$want" ] && same=1 || same=0
  fi
  [ "$same" = 1 ] && return 0

  if [ "$DOT_MODE" = apply ]; then
    defaults $host write "$domain" "$key" "$type" "$4"
    DOT_CHANGED=1
  fi
  changed "${host:+$host }$domain $key" "$have" "$want"
}

# default_unset [-currentHost] <domain> <key>: back to the macOS default.
default_unset() {
  host=
  [ "$1" = -currentHost ] && { host=-currentHost; shift; }
  have=$(defaults $host read "$1" "$2" 2>/dev/null) || return 0

  if [ "$DOT_MODE" = apply ]; then
    defaults $host delete "$1" "$2"
    DOT_CHANGED=1
  fi
  changed "${host:+$host }$1 $2" "$have" '(unset)'
}

# default_shortcut <domain> <key> <keyCode> <modifierFlags>: a shortcut stored
# as a {keyCode, modifierFlags} dictionary (e.g. Rectangle).
default_shortcut() {
  plist=$(defaults export "$1" - 2>/dev/null)
  have_code=$(printf %s "$plist" | plutil -extract "$2.keyCode" raw -o - - 2>/dev/null) || have_code=
  have_flags=$(printf %s "$plist" | plutil -extract "$2.modifierFlags" raw -o - - 2>/dev/null) || have_flags=
  [ "$have_code" = "$3" ] && [ "$have_flags" = "$4" ] && return 0

  if [ "$DOT_MODE" = apply ]; then
    defaults write "$1" "$2" -dict keyCode -int "$3" modifierFlags -int "$4"
    DOT_CHANGED=1
  fi
  have='(unset)'; [ -n "$have_code" ] && have="key $have_code, flags $have_flags"
  changed "$1 $2" "$have" "key $3, flags $4"
}
