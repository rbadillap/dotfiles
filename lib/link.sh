# Files from this repo linked into $HOME. Sourced by dot.
# The link means an app that edits its own settings writes into the repo, so
# the change shows up in `git diff` instead of being lost.

# link <repo path> <target path>: <target> is a symlink to $DOT_ROOT/<repo path>.
# apply backs up a file already at <target> (<target>.backup) instead of
# overwriting it.
link() {
  src=$DOT_ROOT/$1 target=$2
  [ -e "$src" ] || { fail "link: $1 doesn't exist in the repo"; return; }
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
  changed "$(printf %s "$target" | sed "s#^$HOME#~#")" "$have" "link to repo $1"
}
