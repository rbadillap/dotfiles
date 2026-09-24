# EDITOR and VISUAL follow git's core.editor, set by `dot apply editor`.
if editor=$(git config --global core.editor 2>/dev/null); then
  export EDITOR=$editor VISUAL=$editor
fi
unset editor
