# Editor

## Default editor

Which editor you use is a personal value, in `dot.conf`:

    editor=zed    # zed, code, cursor, nvim, vim or nano

`./dot apply editor` sets git's `core.editor` (`zed --wait`: GUI editors wait
until you close the file). `shell/editor.zsh` exports the same command as
`EDITOR` and `VISUAL`, so every tool that opens an editor agrees.

## Zed settings

Zed comes from `config/apps.sh`. Its settings live in the repo:

    ./dot apply zed    # ~/.config/zed/settings.json → home/.config/zed/settings.json

The file is **linked**, not copied. When you change a setting in Zed, Zed
writes it into the repo; `git diff` shows it, and you commit or discard it.
If a settings file already exists, `apply` keeps it as
`settings.json.backup`.

Keep `settings.json` plain JSON without comments: Zed rewrites the file on
every change and doesn't keep comments in place.
