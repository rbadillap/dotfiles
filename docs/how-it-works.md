# How it works

## Three layers

Each setting passes through three layers:

    config/trackpad.sh     trackpad tap-to-click true           what you want
            ↓
    catalog/trackpad.sh    trackpad_tap_to_click()              what it means
            ↓
    lib/defaults.sh        default <domain> <key> <type> <val>  how macOS does it

- **config/** is data and is never executed: one `<topic> <setting> <value>`
  per line. A word like `$hostname` is replaced by its value from `dot.conf`.
- **catalog/** has one function per setting. It validates the value and
  expands it into what the system needs. Tap-to-click, for example, is
  three keys: built-in trackpad, Bluetooth trackpad and a per-host global.
- **lib/** has one file per tool (`defaults`, `scutil`, `git`, `brew`, `ssh`,
  `gh`, `link`, `file`, `keys`). It is the only code that reads or changes the
  system, and it's where check and apply differ.
- **dot** ties them together and only accepts settings defined in catalog/.

The engine is POSIX shell plus tools that ship with macOS and git from the
Command Line Tools, so it runs right after the installer.

## Files in your home folder

- **home/** mirrors `~`. `home/.config/zed/settings.json` is linked to
  `~/.config/zed/settings.json`, so an app that edits its settings writes
  into the repo, and `git diff` shows the change. If a file is already there,
  `apply` keeps it as `<file>.backup`.
- **Shared files** such as `~/.zshrc` and `~/.ssh/config` are never owned by
  the repo. `dot` adds one marked block and leaves the rest to you and your
  tools; `check` lists the rest as notes.
- **shell/** holds the zsh setup, one file per topic
  ([shell.md](shell.md)).

## Personal values

`dot.conf` (ignored by git) holds everything personal; `dot.conf.example` is
its public template. config/ refers to values as `$name`, so a fork changes
one file, not the config.

## Adding a setting

1. Find how macOS stores it (for example, `defaults read` before and after
   changing it in System Settings).
2. Add a function `<topic>_<setting>()` to `catalog/<topic>.sh`, with a
   comment giving its syntax and values. It validates the input and calls
   lib/ functions.
3. Add its line to a `config/<theme>.sh` file, and a row to
   [settings.md](settings.md).
4. Try it with `./dot check <theme>`, then `./dot apply <theme>`.

New files in config/, catalog/ and lib/ are picked up automatically.
[AGENTS.md](../AGENTS.md) has the exact conventions.
