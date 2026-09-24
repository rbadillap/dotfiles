# Runs settings from config/ in check or apply mode. Used by dot check and
# dot apply; expects DOT_ROOT and DOT_MODE.

DOT_DRIFT=$(mktemp)
DOT_EFFECTS=$(mktemp)
DOT_RESTARTS=$(mktemp)
trap 'rm -f "$DOT_DRIFT" "$DOT_EFFECTS" "$DOT_RESTARTS"' EXIT
export DOT_DRIFT DOT_EFFECTS DOT_RESTARTS

for f in "$DOT_ROOT"/src/lib/*.sh; do
  case $f in */run.sh) ;; *) . "$f" ;; esac
done
for f in "$DOT_ROOT"/src/settings/*.sh; do . "$f"; done

# Values from dot.toml, as "<path>=<value>" lines (src/lib/conf.sh).
if [ ! -f "$DOT_ROOT/dot.toml" ]; then
  echo "dot: dot.toml not found. Create it from the example and edit it:" >&2
  echo "  cp \"$DOT_ROOT/dot.toml.example\" \"$DOT_ROOT/dot.toml\"" >&2
  exit 2
fi
DOT_CONF=$(conf_parse "$DOT_ROOT/dot.toml") || exit 2

# resolve <word>: $path becomes its value from dot.toml; $path.* stays the
# table's path, for settings that read each table under it (conf_tables).
# Other words pass through.
resolve() {
  case $1 in
    \$*) path=${1#\$}
      case $path in
        *.\*) path=${path%.\*}; star=1 ;;
        *) star=0 ;;
      esac
      case $path in *[!A-Za-z0-9_.-]*|''|.*|*.|*..*) fail "invalid reference: $1"; return 1 ;; esac
      if [ "$star" = 1 ]; then printf %s "$path"; return 0; fi
      conf_get "$path" && return 0
      if [ -n "$(conf_tables "$path")" ]; then
        fail "$1 is a table: use $1.* to pass the tables under it"
      else
        fail "$1: $path is not set in dot.toml"
      fi
      return 1 ;;
    *) printf %s "$1" ;;
  esac
}

# run_setting <topic> <setting> [<value>...]: one setting.
run_setting() {
  topic=$1 name=$2
  shift 2
  case $topic$name in *[!a-z0-9-]*|'') fail "invalid setting: $topic $name"; return ;; esac
  fn="${topic}_$(printf %s "$name" | tr - _)"
  # Only functions in src/settings/ are settings; lib functions can't be called this way.
  if ! grep -qx "$fn() {" "$DOT_ROOT/src/settings/$topic.sh" 2>/dev/null; then
    fail "unknown setting: $topic $name (see 'dot explain')"
    return
  fi
  # Resolve $path references from dot.toml, keeping the argument list intact.
  # A table reference ($aws.*) is shown as written.
  n=$# shown=
  while [ "$n" -gt 0 ]; do
    word=$(resolve "$1") || return 0
    case $1 in \$*.\*) shown="$shown $1" ;; *) shown="$shown $word" ;; esac
    shift
    set -- "$@" "$word"
    n=$((n - 1))
  done
  begin_setting "$topic $name$shown"
  "$fn" "$@"
  end_setting
}

# run_file <path>: every line of a config file. Config files are data, not
# code: each line is "<topic> <setting> <value>". The file is read on fd 3 so
# commands run by a setting (brew, sudo…) keep the real stdin.
run_file() {
  while read -r topic name value <&3 || [ -n "$topic" ]; do
    case $topic in ''|'#'*) continue ;; esac
    set -f
    run_setting "$topic" "$name" $value
    set +f
  done 3< "$1"
}

# run <args>: what dot check and dot apply do with their arguments.
#   (none)                      every file in config/
#   <file>                      config/<file>.conf
#   <topic> <setting> <value>   one setting
run() {
  if [ $# -eq 0 ]; then
    for f in "$DOT_ROOT"/config/*.conf; do run_file "$f"; done
    [ "$DOT_MODE" = check ] && conf_backup_status
  elif [ $# -eq 1 ]; then
    case $1 in
      -*) echo "dot: unknown flag '$1'" >&2; exit 2 ;;
      *[!a-z0-9-]*) echo "dot: invalid name '$1'" >&2; exit 2 ;;
    esac
    file=$DOT_ROOT/config/$1.conf
    if [ ! -f "$file" ]; then
      echo "dot: no config/$1.conf. Files: $(cd "$DOT_ROOT/config" && ls *.conf | sed 's/\.conf$//' | tr '\n' ' ')" >&2
      exit 2
    fi
    run_file "$file"
  else
    run_setting "$@"
  fi
  report
}

# conf_backup_status: part of a full dot check. dot.toml isn't in git, so its
# backup in 1Password must follow it; dot conf backup updates it.
conf_backup_status() {
  begin_setting "dot.toml backup"
  case $(op_backup_state "dotfiles: dot.toml" "$DOT_ROOT/dot.toml") in
    changed) changed "1Password \"dotfiles: dot.toml\"" "changed since the last backup" "run: dot conf backup" ;;
    never)   changed "1Password \"dotfiles: dot.toml\"" "not backed up from this Mac" "run: dot conf backup, or dot conf restore" ;;
  esac
  end_setting
}
