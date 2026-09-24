# Blocks of text inside files. Sourced by dot.
# The file stays yours and other tools may edit it: only the block is managed,
# and nothing else in the file is ever rewritten.

# file_block <path> <mode> <content>: <content> appears verbatim in <path>.
# apply appends it (creating the file with <mode> if needed).
file_block() {
  if [ -f "$1" ] && FB_CONTENT=$3 awk 'BEGIN { RS = "\001"; c = ENVIRON["FB_CONTENT"] } index($0, c) { f = 1 } END { exit !f }' "$1"; then
    return 0
  fi
  if [ "$DOT_MODE" = apply ]; then
    mkdir -p "$(dirname "$1")"
    if [ -s "$1" ] && [ -n "$(tail -c 1 "$1")" ]; then echo >> "$1"; fi
    printf '%s\n' "$3" >> "$1"
    chmod "$2" "$1"
    DOT_CHANGED=1
  fi
  changed "$(printf %s "$1" | sed "s#^$HOME#~#")" "block missing" "block added"
}
