# Files from this repo linked into $HOME. Sourced by dot.
# Links point into the live copy (src/lib/live.sh), never the working copy, so
# what runs is what's on main. An app that edits its own settings writes into
# the live copy, where `dot check` notes it until it moves into the repo.

# link <repo path> <target path>: <target> is a symlink to $DOT_LIVE/<repo path>.
# apply backs up a file already at <target> (<target>.backup) instead of
# overwriting it.
link() {
  src=$DOT_LIVE/$1 target=$2
  live_exists || { fail "link: no live copy at ~/.local/share/dotfiles/live; run dot update"; return; }
  [ -e "$src" ] || { fail "link: $1 isn't in the live copy (merged to main, then dot update?)"; return; }
  if [ -L "$target" ]; then
    have="link to $(readlink "$target" | sed "s#^$HOME#~#")"
    [ "$(readlink "$target")" = "$src" ] && return 0
  elif [ -e "$target" ]; then
    have="a file"
  else
    have="missing"
  fi

  if [ "$DOT_MODE" = apply ]; then
    mkdir -p "$(dirname "$target")"
    if [ -L "$target" ]; then
      rm "$target"
    elif [ -e "$target" ]; then
      backup=$target.backup
      [ -e "$backup" ] && backup=$target.backup.$(date +%Y%m%d%H%M%S)
      mv "$target" "$backup"
      note "kept the previous file as $(printf %s "$backup" | sed "s#^$HOME#~#")"
    fi
    ln -s "$src" "$target"
    DOT_CHANGED=1
  fi
  changed "$(printf %s "$target" | sed "s#^$HOME#~#")" "$have" "link to live copy $1"
}
