# Using dot

`dot` compares the Mac with what `config/` declares, and fixes the
differences. It's on `PATH` once the shell is set up ([shell.md](shell.md)),
so it works from any folder; before that, run `./dot` from the repo.

    ./dot check                          # everything; changes nothing
    ./dot apply                          # fix every difference
    ./dot check <theme>                  # one file: config/<theme>.sh
    ./dot apply <topic> <setting> <value>  # one setting, not saved anywhere
    ./dot --help                         # usage (-h works anywhere on the line)

## Output

    ✓ dock visibility hidden
    ~ keyboard repeat-rate 2
        NSGlobalDomain KeyRepeat: 5 → 2
    ~ system hostname ronny
        ComputerName: Ronny’s MacBook Pro → ronny  (sudo)
    ✓ shell init zsh
        · not from this repo: source ~/.config/op/plugins.sh
    ! mouse secondary-click: expected right, left or off, got 'middle'

| Mark | Meaning                                                            |
|------|--------------------------------------------------------------------|
| `✓`  | matches                                                            |
| `~`  | differs; each indented line is an underlying value and its target  |
| `→`  | changed by `apply`                                                 |
| `!`  | error: an invalid value or a failed step; nothing changed for it   |
| `·`  | a note: information only, never a difference                       |
| `(sudo)` | needs your password; `apply` asks for it                        |

`apply` changes only what differs, so running it twice is safe. At the end
it restarts apps that need it (the Dock, Rectangle) and lists anything left
for you, such as logging out.

## Trying a setting live

The single-setting form applies without saving:

    ./dot apply keyboard repeat-rate 1

If you like it, copy the same line (`keyboard repeat-rate 1`) into its
`config/` file. If not, apply the previous value.

## Exit codes

| Code | Meaning                                                           |
|------|-------------------------------------------------------------------|
| `0`  | everything matches (check) or was applied (apply)                 |
| `1`  | differences found, or a setting had an error                      |
| `2`  | bad usage (unknown command, option or theme), or `dot.conf` missing |

Without a terminal (agents, logs), output is plain text without colors.
`NO_COLOR` also turns colors off.
