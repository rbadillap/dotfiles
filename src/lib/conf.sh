# dot.toml: the owner's personal values, in a subset of TOML. Sourced by dot.
#
# Accepted: comments, [table.headers] and key = "string" (or 'string') lines,
# with keys and table names made of letters, digits, _ and -. Anything else
# TOML allows (numbers, booleans, arrays, inline tables, dotted keys,
# multi-line strings) is refused with an error, never skipped.

# conf_parse <file>: prints every value as "<path>=<value>", where <path> is
# the table and key joined by dots (git.identity.work.email). On a syntax
# error it prints the file and line, and exits 2.
conf_parse() {
  awk -v file="$(printf %s "$1" | sed "s#^$HOME#~#")" '
    function err(msg) { printf "dot: %s:%d: %s\n", file, NR, msg > "/dev/stderr"; exit 2 }
    {
      line = $0
      sub(/^[ \t]+/, "", line)
      if (line == "" || substr(line, 1, 1) == "#") next

      if (substr(line, 1, 1) == "[") {
        if (substr(line, 1, 2) == "[[") err("arrays of tables are not supported")
        if (line !~ /^\[[ \t]*[A-Za-z0-9_-]+([ \t]*\.[ \t]*[A-Za-z0-9_-]+)*[ \t]*\][ \t]*(#.*)?$/)
          err("expected a table header such as [git] or [aws.work]")
        table = line
        sub(/\].*$/, "", table); sub(/^\[/, "", table); gsub(/[ \t]/, "", table)
        if (("[" table) in seen) err("table [" table "] is defined twice")
        seen["[" table] = 1
        next
      }

      if (!match(line, /^[A-Za-z0-9_-]+[ \t]*=/)) {
        if (line ~ /^[A-Za-z0-9_.-]+[ \t]*=/) err("dotted keys are not supported: use a [table] header")
        err("expected key = \"value\"")
      }
      key = substr(line, 1, RLENGTH - 1); sub(/[ \t]+$/, "", key)
      rest = substr(line, RLENGTH + 1); sub(/^[ \t]+/, "", rest)

      q = substr(rest, 1, 1)
      if (q != "\"" && q != "\047") err("only strings are supported: put the value in quotes")
      if (substr(rest, 1, 3) == q q q) err("multi-line strings are not supported")
      value = ""; closed = 0; n = length(rest)
      for (i = 2; i <= n; i++) {
        c = substr(rest, i, 1)
        if (c == q) { closed = 1; i++; break }
        if (c == "\\" && q == "\"") {
          d = substr(rest, i + 1, 1)
          if (d != "\"" && d != "\\") err("unsupported escape \\" d ": only \\\" and \\\\ are supported")
          value = value d; i++; continue
        }
        value = value c
      }
      if (!closed) err("the string is not closed")
      after = substr(rest, i); sub(/^[ \t]+/, "", after)
      if (after != "" && substr(after, 1, 1) != "#") err("unexpected text after the value")

      path = table == "" ? key : table "." key
      if (path in seen) err(path " is defined twice")
      seen[path] = 1
      print path "=" value
    }
  ' "$1"
}

# conf_get <path>: prints the value at <path> from DOT_CONF (conf_parse's
# output). Returns 1 if it isn't set.
conf_get() {
  printf '%s\n' "$DOT_CONF" | awk -v p="$1=" '
    index($0, p) == 1 { print substr($0, length(p) + 1); found = 1; exit }
    END { exit !found }'
}

# conf_tables <path>: prints the names of the tables directly under <path>,
# in file order: for [aws.work] and [aws.home], conf_tables aws prints work
# and home.
conf_tables() {
  printf '%s\n' "$DOT_CONF" | awk -v p="$1." '
    index($0, p) == 1 {
      rest = substr($0, length(p) + 1)
      key = substr(rest, 1, index(rest, "=") - 1)
      dot = index(key, ".")
      if (dot) { name = substr(key, 1, dot - 1); if (!(name in seen)) { seen[name] = 1; print name } }
    }'
}
