# Shell

zsh (macOS's default shell), without a framework, and the
[Starship](https://starship.rs) prompt from `config/packages.sh`.

    ./dot apply packages   # installs Starship
    ./dot apply shell      # connects ~/.zshrc to this repo

## ~/.zshrc stays yours

Tools such as Homebrew and 1Password ask you to append lines to `~/.zshrc`,
and they're free to. The repo never owns or rewrites the file:
`shell init zsh` adds one marked block that loads the repo's setup.

    # >>> dotfiles: managed by ./dot apply shell
    source "/Users/you/code/<owner>/dotfiles/shell/init.zsh"
    # <<< dotfiles

`./dot check shell` lists every other line as a note, so you notice what
tools added and can move it into `shell/` or leave it:

    ✓ shell init zsh
        · not from this repo: source /Users/you/.config/op/plugins.sh

## shell/

One file per topic, loaded by `shell/init.zsh` in this order:

| File                | Does                                                 |
|---------------------|------------------------------------------------------|
| `shell/path.zsh`    | Homebrew: `PATH`, `MANPATH`, completions             |
| `shell/op.zsh`      | 1Password shell plugins: `gh` gets its token from 1Password |
| `shell/editor.zsh`  | `EDITOR` and `VISUAL`, from git's `core.editor` ([editor.md](editor.md)) |
| `shell/prompt.zsh`  | Starship                                             |

To add a topic, create `shell/<topic>.zsh` and add it to the list in
`shell/init.zsh`.

## Terminal and font

[Ghostty](https://ghostty.org), from `config/apps.sh`, includes JetBrains Mono
with the Nerd Font symbols Starship uses, so it needs no font setup. Other
apps can use JetBrains Mono Nerd Font from `config/fonts.sh`.
