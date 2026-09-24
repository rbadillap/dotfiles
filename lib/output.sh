# Output shared by every lib: one line per setting, details only for what
# differs, effects, and the final summary. Sourced by dot.

# Colors only on a terminal, and never with NO_COLOR, so agents and logs get
# plain text.
if [ -t 1 ] && [ -z "${NO_COLOR:-}" ]; then
  c_ok=$(printf '\033[32m') c_diff=$(printf '\033[33m') c_apply=$(printf '\033[36m')
  c_err=$(printf '\033[31m') c_off=$(printf '\033[0m')
else
  c_ok= c_diff= c_apply= c_err= c_off=
fi

begin_setting() { DOT_LABEL=$1 DOT_DIRTY=0 DOT_CHANGED=0 DOT_NOTES=; }

end_setting() {
  [ "$DOT_DIRTY" = 1 ] || printf '  %s✓%s %s\n' "$c_ok" "$c_off" "$DOT_LABEL"
  [ -z "$DOT_NOTES" ] || printf %s "$DOT_NOTES"
}

# note <text>: information shown under the setting. Never counts as a
# difference or an error.
note() {
  DOT_NOTES="$DOT_NOTES$(printf '      · %s' "$1")
"
}

# detail <text>: print the setting header once, then an indented detail line.
detail() {
  if [ "$DOT_DIRTY" = 0 ]; then
    if [ "$DOT_MODE" = check ]; then
      printf '  %s~%s %s\n' "$c_diff" "$c_off" "$DOT_LABEL"
    else
      printf '  %s→%s %s\n' "$c_apply" "$c_off" "$DOT_LABEL"
    fi
    DOT_DIRTY=1
  fi
  printf '      %s\n' "$1"
}

# changed <what> <from> <to> [note]: report a difference, or a change just made.
changed() {
  detail "$1: $2 → $3${4:+  ($4)}"
  [ "$DOT_MODE" = check ] && echo x >> "$DOT_DRIFT"
  return 0
}

fail() {
  printf '  %s!%s %s\n' "$c_err" "$c_off" "$*" >&2
  DOT_DIRTY=1
  echo error >> "$DOT_DRIFT"
}

# effect <text>: something the user must do for this setting to take effect.
# No-op unless the setting changed something.
effect() {
  [ "${DOT_CHANGED:-0}" = 1 ] || return 0
  grep -qxF "$1" "$DOT_EFFECTS" 2>/dev/null || echo "$1" >> "$DOT_EFFECTS"
}

# restart <process>: restart an app at the end of apply so the setting takes
# effect. No-op unless the setting changed something.
restart() {
  [ "${DOT_CHANGED:-0}" = 1 ] || return 0
  grep -qxF "$1" "$DOT_RESTARTS" 2>/dev/null || echo "$1" >> "$DOT_RESTARTS"
}

# Exit status: check exits 1 when anything differs; both exit 1 on errors.
report() {
  if [ -s "$DOT_RESTARTS" ]; then
    echo
    while read -r p; do
      killall "$p" 2>/dev/null && echo "Restarted $p." || echo "Could not restart $p; restart it by hand."
    done < "$DOT_RESTARTS"
  fi
  if [ -s "$DOT_EFFECTS" ]; then
    echo
    echo "To take effect:"
    sed 's/^/  - /' "$DOT_EFFECTS"
  fi
  if [ -s "$DOT_DRIFT" ]; then
    if grep -qx error "$DOT_DRIFT"; then
      echo; echo "Errors found; nothing was changed for those settings."
    elif [ "$DOT_MODE" = check ]; then
      echo; echo "Differences found. Run 'dot apply' to fix them."
    fi
    exit 1
  fi
}
