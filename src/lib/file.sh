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

# file_managed_block <path> <mode> <content>: <content> starts with a line
# "# >>> <name>" and ends with "# <<< <name>". The block with those markers is
# kept in <path>: added if missing, replaced if different. Nothing outside it
# is ever touched.
file_managed_block() {
  # The block is recognized by its marker ("# >>> name"), whatever follows it.
  begin=$(printf '%s\n' "$3" | head -1 | sed 's/:.*//') end=$(printf '%s\n' "$3" | tail -1)
  if [ -f "$1" ] && FB_CONTENT=$3 awk 'BEGIN { RS = "\001"; c = ENVIRON["FB_CONTENT"] } index($0, c) { f = 1 } END { exit !f }' "$1"; then
    return 0
  fi
  if [ -f "$1" ] && grep -q "^$begin" "$1"; then
    # Replacing runs from the begin marker to the end marker, so a missing,
    # stray or repeated marker would swallow lines outside the block: refuse.
    if ! FB_BEGIN=$begin FB_END=$end awk '
      index($0, ENVIRON["FB_BEGIN"]) == 1 { if (seen) bad = 1; seen = open = 1; next }
      $0 == ENVIRON["FB_END"] { if (!open) bad = 1; open = 0 }
      END { exit bad || open }
    ' "$1"; then
      fail "$(printf %s "$1" | sed "s#^$HOME#~#"): its \"$begin\" block is unclosed or repeated; fix it by hand"
      return 0
    fi
    have="block outdated" want="block updated"
  else
    have="block missing" want="block added"
  fi
  if [ "$DOT_MODE" = apply ]; then
    mkdir -p "$(dirname "$1")"
    if [ "$have" = "block outdated" ]; then
      tmp=$(mktemp)
      FB_CONTENT=$3 FB_BEGIN=$begin FB_END=$end awk '
        index($0, ENVIRON["FB_BEGIN"]) == 1 { print ENVIRON["FB_CONTENT"]; skip = 1; next }
        skip && $0 == ENVIRON["FB_END"] { skip = 0; next }
        !skip { print }
      ' "$1" > "$tmp"
      cat "$tmp" > "$1" && rm -f "$tmp"   # rewrite in place, keeping the file's owner and links
    else
      if [ -s "$1" ] && [ -n "$(tail -c 1 "$1")" ]; then echo >> "$1"; fi
      printf '%s\n' "$3" >> "$1"
    fi
    chmod "$2" "$1"
    DOT_CHANGED=1
  fi
  changed "$(printf %s "$1" | sed "s#^$HOME#~#")" "$have" "$want"
}
