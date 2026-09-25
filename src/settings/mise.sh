# mise: versions of Node, pnpm, Bun, Python, uv and other tools, globally and per project
# (https://mise.jdx.dev). Installed by `brew formula mise`.

# mise config <linked>   ~/.config/mise/config.toml is a link to this repo's
# config/home/.config/mise/config.toml, the global tool versions
mise_config() {
  [ "$1" = linked ] || { fail "mise config: only 'linked' is supported, got '$1'"; return; }
  link config/home/.config/mise/config.toml "$HOME/.config/mise/config.toml"
}

# mise tools <installed>   every tool in the global config is installed
mise_tools() {
  [ "$1" = installed ] || { fail "mise tools: only 'installed' is supported, got '$1'"; return; }
  command -v mise >/dev/null 2>&1 || { fail "mise isn't installed (brew formula mise)"; return; }
  # Captured before the pipe, which would hide a failed query as "nothing missing".
  list=$(mise ls --global --missing 2>/dev/null) || { fail "mise ls failed: can't tell which tools are missing"; return; }
  missing=$(printf '%s\n' "$list" | awk 'NF { print $1 "@" $2 }' | tr '\n' ' ')
  [ -n "$missing" ] || return 0
  if [ "$DOT_MODE" = apply ]; then
    out=$(mise install --yes 2>&1) || { fail "mise install failed: $(printf %s "$out" | tail -1)"; return; }
    DOT_CHANGED=1
  fi
  changed "mise" "missing: $missing" "installed"
}
