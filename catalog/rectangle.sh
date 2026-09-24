# Rectangle (window tiling): https://rectangleapp.com. Installed from
# config/apps.sh; it needs Accessibility permission once (manual).

# rectangle shortcut <action> <combo>
# <action>: left-half right-half center-half first-third center-third
#   last-third first-two-thirds last-two-thirds first-fourth second-fourth
#   third-fourth last-fourth maximize almost-maximize center
# <combo>: e.g. cmd+opt+left, cmd+shift+opt+up (see lib/keys.sh)
rectangle_shortcut() {
  case $1 in
    left-half|right-half|center-half|first-third|center-third|last-third|\
    first-two-thirds|last-two-thirds|first-fourth|second-fourth|third-fourth|\
    last-fourth|maximize|almost-maximize|center) ;;
    *) fail "rectangle shortcut: unknown action '$1'"; return ;;
  esac
  # first-two-thirds → firstTwoThirds, as Rectangle names its preferences
  action=$(printf %s "$1" | awk -F- '{ s = $1; for (i = 2; i <= NF; i++) s = s toupper(substr($i, 1, 1)) substr($i, 2); print s }')
  key_combo "$2" || { fail "rectangle shortcut: invalid combo '$2'"; return; }
  default_shortcut com.knollsoft.Rectangle "$action" "$KEY_CODE" "$KEY_FLAGS"
  restart Rectangle
}
