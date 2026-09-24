# Shell

zsh (macOS's default shell), without a framework, and the
[Starship](https://starship.rs) prompt from `config/packages.conf`.

    dot apply packages   # installs Starship
    dot apply shell      # connects ~/.zshrc to this repo

## ~/.zshrc stays yours

Tools such as Homebrew and 1Password ask you to append lines to `~/.zshrc`,
and they're free to. The repo never owns or rewrites the file:
`shell init zsh` keeps one marked block in it.

    # >>> dotfiles: managed by dot apply shell
    eval "$("/Users/you/code/<owner>/dotfiles/dot" init zsh)"
    # <<< dotfiles

`dot check shell` lists every other line as a note, so you notice what tools
added and can move it into `config/shell/` or leave it:

    ✓ shell init zsh
        · not from this repo: source /Users/you/.config/op/plugins.sh

## What `dot init zsh` sets up

1. **Homebrew**: `PATH`, `MANPATH` and completions.
2. **dot**, as a shell function: `dot clone`, `dot fork` and `dot cd` take you
   to the folder.
3. **Completion** for `dot` ([dot.md](dot.md)).
4. **Your files** in `config/shell/`, in alphabetical order:

| File                        | Does                                                  |
|-----------------------------|-------------------------------------------------------|
| `config/shell/editor.zsh`   | `EDITOR` and `VISUAL`, from git's `core.editor` ([editor.md](editor.md)) |
| `config/shell/op.zsh`       | 1Password shell plugins: `gh` gets its token from 1Password |
| `config/shell/prompt.zsh`   | Starship                                              |

To add something to your shell, create `config/shell/<topic>.zsh`.

## Terminal and font

[Ghostty](https://ghostty.org), from `config/apps.conf`, includes JetBrains
Mono with the Nerd Font symbols Starship uses, so it needs no font setup.
Other apps can use JetBrains Mono Nerd Font from `config/fonts.conf`.
