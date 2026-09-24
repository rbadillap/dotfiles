# Default editor.

# editor default <zed|code|cursor|nvim|vim|nano>   the editor git opens (commit
# messages, rebases). The shell exports the same command as EDITOR and VISUAL
# (config/shell/editor.zsh reads it from git), so there's one source of truth.
editor_default() {
  case $1 in
    zed|code|cursor) cmd="$1 --wait" ;;   # GUI editors must wait for the file to close
    nvim|vim|nano)   cmd=$1 ;;
    *) fail "editor default: unsupported editor '$1'"; return ;;
  esac
  gitconfig core.editor "$cmd"
}
