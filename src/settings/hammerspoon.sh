# Hammerspoon (desktop automation in Lua): https://www.hammerspoon.org.
# Installed from config/apps.conf; it needs Accessibility permission once
# (manual).

# hammerspoon config <linked>   ~/.hammerspoon/init.lua and each automation
# it loads (windows.lua) are links to this repo's config/home/.hammerspoon/
hammerspoon_config() {
  [ "$1" = linked ] || { fail "hammerspoon config: only 'linked' is supported, got '$1'"; return; }
  for f in init.lua windows.lua; do
    link "config/home/.hammerspoon/$f" "$HOME/.hammerspoon/$f"
  done
  restart Hammerspoon
}

# hammerspoon tile <combo> <from>-<to>   the shortcut puts the focused window
# in that range of the screen's width, in percent: 0-30 is the left 30%.
# <combo>: e.g. cmd+opt+left, cmd+shift+opt+up (see src/lib/keys.sh). Kept in
# ~/.hammerspoon/tiles; deleting a line leaves its block there, to remove by
# hand.
hammerspoon_tile() {
  key_combo "$1" || { fail "hammerspoon tile: invalid combo '$1'"; return; }
  case $2 in [0-9]*-[0-9]*) ;; *) fail "hammerspoon tile: range must be <from>-<to> in percent, got '$2'"; return ;; esac
  from=${2%%-*} to=${2#*-}
  case $from$to in *[!0-9]*) fail "hammerspoon tile: range must be <from>-<to> in percent, got '$2'"; return ;; esac
  [ "$from" -lt "$to" ] && [ "$to" -le 100 ] || { fail "hammerspoon tile: range must go up, from 0 to 100, got '$2'"; return; }
  file_managed_block "$HOME/.hammerspoon/tiles" 644 "# >>> [$1]
$1 $from $to
# <<< [$1]"
  restart Hammerspoon
}
