# Zed settings.

# zed settings <linked>   ~/.config/zed/settings.json is a link to this repo's
# home/.config/zed/settings.json
zed_settings() {
  [ "$1" = linked ] || { fail "zed settings: only 'linked' is supported, got '$1'"; return; }
  link home/.config/zed/settings.json "$HOME/.config/zed/settings.json"
}
