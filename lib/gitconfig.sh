# Global git settings via git-config(1), stored in ~/.gitconfig. Sourced by dot.

# gitconfig <key> <value>
gitconfig() {
  have=$(git config --global --get "$1" 2>/dev/null) || have='(unset)'
  [ "$have" = "$2" ] && return 0

  if [ "$DOT_MODE" = apply ]; then
    git config --global "$1" "$2"
    DOT_CHANGED=1
  fi
  changed "git $1" "$have" "$2"
}
