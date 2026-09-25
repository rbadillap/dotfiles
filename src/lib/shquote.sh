# Quoting for generated shell code. Sourced by dot.

# shquote <value>: prints <value> as a single-quoted shell literal, so code
# that embeds it (a path in ~/.zshrc, say) never expands `$(...)` or `$VAR`
# inside it. A ' in the value becomes '\''.
shquote() {
  printf "'%s'" "$(printf '%s' "$1" | sed "s/'/'\\\\''/g")"
}
