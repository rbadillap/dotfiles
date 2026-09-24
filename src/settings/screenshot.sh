# Screenshot settings (⌘⇧3, ⌘⇧4, ⌘⇧5).

# screenshot save-to <clipboard|desktop|preview>   where ⌘⇧3 and ⌘⇧4 send the
# screenshot: clipboard leaves no file (paste it with ⌘V), desktop is macOS's
# default, preview opens it in Preview. Adding ⌃ to the shortcut always copies.
screenshot_save_to() {
  case $1 in
    clipboard|preview) default com.apple.screencapture target -string "$1" ;;
    desktop)           default_unset com.apple.screencapture target ;;
    *) fail "screenshot save-to: expected clipboard, desktop or preview, got '$1'"; return ;;
  esac
  restart SystemUIServer
}
