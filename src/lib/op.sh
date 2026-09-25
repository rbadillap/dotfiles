# Files backed up to 1Password as Document items, via op(1). Used by
# dot conf; dot check reports the backup's state.

# Where the last upload of each file is recorded (per Mac, outside the repo).
DOT_STATE=${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles

# op_record <title>: the file that records the last upload of <title>.
op_record() {
  printf '%s/%s.sha256' "$DOT_STATE" "$(printf %s "$1" | tr -cs 'A-Za-z0-9\n' - | sed 's/-*$//')"
}

# op_backup_state <title> <file>: prints "same", "changed" (since the last
# backup from this Mac) or "never". Reads only the local record: no Touch ID.
op_backup_state() {
  have=$(cat "$(op_record "$1")" 2>/dev/null) || { echo never; return; }
  if [ "$have" = "$(shasum -a 256 "$2" | cut -d' ' -f1)" ]; then echo same; else echo changed; fi
}

# op_document <title> <file>: <file> is backed up to 1Password as the Document
# <title>, tagged "dotfiles", in the account's built-in personal vault.
# A Mac that never backed up or restored doesn't overwrite an existing backup,
# since its file may be wizard defaults, unless DOT_FORCE=1.
op_document() {
  [ -f "$2" ] || { fail "$2 doesn't exist"; return; }
  state=$(op_backup_state "$1" "$2")
  [ "$state" = same ] && return 0

  if [ "$DOT_MODE" = apply ]; then
    if op document get "$1" >/dev/null 2>&1; then
      if [ "$state" = never ] && [ "${DOT_FORCE:-0}" != 1 ]; then
        fail "1Password already has \"$1\", and this Mac hasn't restored it. Restore it first (dot conf restore), or replace it with --force."
        return
      fi
      op document edit "$1" "$2" --tags dotfiles >/dev/null || { fail "op document edit '$1' failed"; return; }
    else
      op document create "$2" --title "$1" --tags dotfiles >/dev/null || { fail "op document create '$1' failed"; return; }
    fi
    mkdir -p "$DOT_STATE"
    shasum -a 256 "$2" | cut -d' ' -f1 > "$(op_record "$1")"
    DOT_CHANGED=1
  fi
  if [ "$state" = changed ]; then from="changed since the last backup"; else from="not backed up from this Mac"; fi
  changed "1Password \"$1\"" "$from" "backed up"
}

# Project secrets, for dot secret: API Credential items tagged "dotfiles" in
# the vault set under [secrets] in dot.toml. A value only ever travels
# through pipes, never as an argument (visible in the process list) or a file.

# op_secret_ref <vault> <name>: the reference a .env.schema uses.
op_secret_ref() { printf 'op://%s/%s/credential' "$1" "$2"; }

# op_secret_exists <vault> <name>: true if the item exists. Fails on any
# other error (not signed in, no such vault).
op_secret_exists() {
  err=$(op item get "$2" --vault "$1" --format json 2>&1 >/dev/null) && return 0
  case $err in *"isn't an item"*|*"not found"*) return 1 ;; esac
  printf '%s\n' "$err" | sed 's/^\[ERROR\] [0-9/]* [0-9:]* //' >&2
  exit 1
}

# op_secret_add <vault> <name>: creates the item with the value on stdin.
op_secret_add() {
  /usr/bin/jq -Rs --arg title "$2" '{title: $title, category: "API_CREDENTIAL", tags: ["dotfiles"],
    fields: [{id: "credential", type: "CONCEALED", label: "credential", value: .}]}' |
    op item create --vault "$1" --format json - >/dev/null
}

# op_secret_update <vault> <name>: replaces the item's value with stdin,
# keeping everything else in the item.
op_secret_update() {
  # Read first: in a pipe, a failed read would reach the edit as empty input.
  # printf is a builtin, so the item never becomes a command's argument.
  item=$(op item get "$2" --vault "$1" --format json) || return
  { /usr/bin/jq -Rs '{value: .}'; printf '%s' "$item"; } |
    /usr/bin/jq -s '.[0].value as $v | .[1] | (.fields[] | select(.id == "credential") | .value) = $v' |
    op item edit "$2" --vault "$1" --format json >/dev/null
}

# op_secret_list <vault>: one line per secret, tab-separated: name, updated.
# Fails when op does: an error must not read as an empty list.
op_secret_list() {
  list=$(op item list --vault "$1" --tags dotfiles --categories "API Credential" --format json) || return
  printf '%s' "$list" | /usr/bin/jq -r 'sort_by(.title)[] | [.title, .updated_at[:10]] | @tsv'
}
