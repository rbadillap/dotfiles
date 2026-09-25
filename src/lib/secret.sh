# Shared steps of the dot secret commands. Sourced by them, and harmless to
# source elsewhere: it only defines functions.

. "$DOT_ROOT/src/lib/conf.sh"
. "$DOT_ROOT/src/lib/op.sh"

# secret_vault <command>: sets vault from [secrets] in dot.toml, or exits 2.
secret_vault() {
  DOT_CONF=$(conf_parse "$DOT_ROOT/dot.toml") || exit 2
  vault=$(conf_get secrets.vault) || {
    echo "dot secret $1: set the vault for project secrets in dot.toml:" >&2
    printf '  [secrets]\n  vault = "Dev"\n' >&2
    exit 2
  }
}

# secret_args <command> <name>: validates the arguments; sets name and vault.
secret_args() {
  cmd=$1; shift
  [ $# -ge 1 ] || { echo "dot secret $cmd: missing <name>. Run 'dot secret $cmd --help'." >&2; exit 2; }
  [ $# -eq 1 ] || { echo "dot secret $cmd: expected one <name>, got $#" >&2; exit 2; }
  case $1 in
    -*) echo "dot secret $cmd: unknown flag '$1'" >&2; exit 2 ;;
    *[!a-z0-9._-]*|[._-]*) echo "dot secret $cmd: invalid name '$1': lowercase letters, digits, '.', '_' and '-', as <project>-<use>" >&2; exit 2 ;;
  esac
  name=$1
  secret_vault "$cmd"
}

# secret_read_value <command>: sets value, asked without echo on a terminal,
# or read whole from stdin when it's piped. Refuses an empty value.
secret_read_value() {
  if [ -t 0 ]; then
    printf 'Value for %s (hidden): ' "$name" >&2
    stty -echo
    trap 'stty echo' EXIT INT TERM
    IFS= read -r value || value=
    stty echo
    trap - EXIT INT TERM
    echo >&2
  else
    value=$(cat)
  fi
  [ -n "$value" ] || { echo "dot secret $1: empty value; nothing saved" >&2; exit 2; }
}

# secret_attach <schema> <VARIABLE> <reference>: appends the variable to the
# schema as a sensitive reference.
secret_attach() {
  if [ -s "$1" ] && [ -n "$(tail -c 1 "$1")" ]; then echo >> "$1"; fi
  printf '\n# @sensitive\n%s=op(%s)\n' "$2" "$3" >> "$1"
}
