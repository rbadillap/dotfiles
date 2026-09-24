# Homebrew: PATH, MANPATH and completions for everything it installs.
[[ -x /opt/homebrew/bin/brew ]] && eval "$(/opt/homebrew/bin/brew shellenv)"

# This repo's own tools: clone, fork, dot (bin/).
path=("${0:A:h:h}/bin" $path)
