# Varlock's own settings, via the varlock command. Used by dot check and apply.

# varlock_telemetry <enable|disable>: Varlock's anonymous usage analytics.
# The state is "telemetryDisabled" in ~/.config/varlock/config.json.
varlock_telemetry_state() {
  command -v varlock >/dev/null 2>&1 || { fail "Varlock isn't installed (dot apply packages)"; return; }
  if /usr/bin/jq -e '.telemetryDisabled == true' "$HOME/.config/varlock/config.json" >/dev/null 2>&1; then
    have=disable
  else
    have=enable
  fi
  [ "$have" = "$1" ] && return 0
  if [ "$DOT_MODE" = apply ]; then
    varlock telemetry "$1" >/dev/null 2>&1 || { fail "varlock telemetry $1 failed"; return; }
    DOT_CHANGED=1
  fi
  changed "Varlock telemetry" "${have}d" "${1}d"
}
