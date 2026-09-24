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

# Values from dot.conf. Names are checked before use, so eval only ever sees
# a plain identifier.
if [ ! -f "$DOT_ROOT/dot.conf" ]; then
  echo "dot: dot.conf not found. Create it from the example and edit it:" >&2
  echo "  cp \"$DOT_ROOT/dot.conf.example\" \"$DOT_ROOT/dot.conf\"" >&2
  exit 2
fi
while IFS== read -r key value || [ -n "$key" ]; do
  case $key in ''|'#'*) continue ;; esac
  case $key in
    *[!a-z0-9_]*) echo "dot: dot.conf: invalid name '$key'" >&2; exit 2 ;;
  esac
  eval "DOTVAR_$key=\$value"
done < "$DOT_ROOT/dot.conf"

# resolve <word>: $name becomes its value from dot.conf; other words pass through.
resolve() {
  case $1 in
    \$*) name=${1#\$}
      case $name in *[!a-z0-9_]*|'') fail "invalid variable: $1"; return 1 ;; esac
      eval "set -- \"\${DOTVAR_$name-\$1}\""
      case $1 in \$*) fail "$1 is not defined in dot.conf"; return 1 ;; esac ;;
  esac
  printf %s "$1"
}

# run_setting <topic> <setting> [<value>...]: one setting.
run_setting() {
  topic=$1 name=$2
  shift 2
  case $topic$name in *[!a-z0-9-]*|'') fail "invalid setting: $topic $name"; return ;; esac
  fn="${topic}_$(printf %s "$name" | tr - _)"
  # Only functions in src/settings/ are settings; lib functions can't be called this way.
  if ! grep -qx "$fn() {" "$DOT_ROOT/src/settings/$topic.sh" 2>/dev/null; then
    fail "unknown setting: $topic $name (see 'dot settings')"
    return
  fi
  # Resolve $name references from dot.conf, keeping the argument list intact.
  n=$#
  while [ "$n" -gt 0 ]; do
    word=$(resolve "$1") || return 0
    shift
    set -- "$@" "$word"
    n=$((n - 1))
  done
  begin_setting "$topic $name $*"
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
