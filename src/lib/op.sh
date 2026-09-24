# Files backed up to 1Password as Document items, via op(1). Sourced by dot.

# Where op_document remembers what it last uploaded (per Mac, outside the repo).
DOT_STATE=${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles

# op_document <title> <file>: <file> is backed up to 1Password as the Document
# <title>, in the account's built-in personal vault, tagged "dotfiles".
# check compares <file> with a local record of the last upload, so it never
# needs Touch ID; apply uploads (Touch ID) and updates that record.
op_document() {
  [ -f "$2" ] || { fail "backup: $2 doesn't exist"; return; }
  record=$DOT_STATE/$(printf %s "$1" | tr -cs 'A-Za-z0-9\n' - | sed 's/-*$//').sha256
  want=$(shasum -a 256 "$2" | cut -d' ' -f1)
  have=$(cat "$record" 2>/dev/null) || have=
  [ "$have" = "$want" ] && return 0

  if [ "$DOT_MODE" = apply ]; then
    if op document get "$1" >/dev/null 2>&1; then
      # A Mac that never backed up or restored must not overwrite an existing
      # backup: its file may be wizard defaults.
      if [ -z "$have" ]; then
        fail "backup: 1Password already has \"$1\", and this Mac hasn't restored it. Restore it first (op document get \"$1\" --out-file <file>), or delete that item to back up this file instead."
        return
      fi
      op document edit "$1" "$2" --tags dotfiles >/dev/null || { fail "op document edit '$1' failed"; return; }
    else
      op document create "$2" --title "$1" --tags dotfiles >/dev/null || { fail "op document create '$1' failed"; return; }
    fi
    mkdir -p "$DOT_STATE"
    printf '%s\n' "$want" > "$record"
    DOT_CHANGED=1
  fi
  if [ -n "$have" ]; then from="changed since the last backup"; else from="not backed up from this Mac"; fi
  changed "1Password \"$1\"" "$from" "backed up"
}
