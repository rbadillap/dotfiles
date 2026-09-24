# clone and fork (bin/) print the repo's path last; these wrappers cd into it.
# Help and errors pass through unchanged.
clone() { _dot_cd_to clone "$@"; }
fork()  { _dot_cd_to fork "$@"; }

_dot_cd_to() {
  local tool=$1 dir; shift
  case $1 in ''|-h|--help|--resolve) command $tool "$@"; return ;; esac
  dir=$(command $tool "$@") || return
  [[ -d $dir ]] && cd "$dir"
}
