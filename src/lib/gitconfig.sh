# Git settings via git-config(1). Sourced by dot.

# gitconfig [-f <file>] <key> <value>: in ~/.gitconfig, or in <file> when given.
gitconfig() {
  where=--global label=git
  if [ "$1" = -f ]; then
    where="--file=$2" label=$(printf %s "$2" | sed "s#^$HOME#~#")
    shift 2
  fi
  have=$(git config "$where" --get "$1" 2>/dev/null) || have='(unset)'
  [ "$have" = "$2" ] && return 0

  if [ "$DOT_MODE" = apply ]; then
    [ "$where" = --global ] || mkdir -p "$(dirname "${where#--file=}")"
    git config "$where" "$1" "$2"
    DOT_CHANGED=1
  fi
  changed "$label $1" "$have" "$2"
}
