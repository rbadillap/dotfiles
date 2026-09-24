# How it works

## Layout

    dot                  the CLI
    install.sh           sets up a clean Mac
    dot.conf             your personal values (ignored by git); template: dot.conf.example
    src/                 the engine; you don't edit it to use the repo
      commands/          one file per command: dot-check, dot-clone…
      settings/          one file per topic: what each setting means
      lib/               shared code, including everything that changes the system
    config/              your setup; a fork edits this and dot.conf
      *.conf             what you want: `dock visibility hidden`
      home/              files linked into ~
      shell/             your zsh setup, one file per topic
    docs/

## Settings: three layers

    config/trackpad.conf     trackpad tap-to-click true           what you want
            ↓
    src/settings/trackpad.sh trackpad_tap_to_click()              what it means
            ↓
    src/lib/defaults.sh      default <domain> <key> <type> <val>  how macOS does it

- **config/*.conf** is data and is never executed: one
  `<topic> <setting> <value>` per line; `#` starts a comment. Files group lines
  however you like (`apps.conf` holds `brew cask …` lines). A word like
  `$hostname` is replaced by its value from `dot.conf`.
- **src/settings/<topic>.sh** has one function per setting. The comment above
  it is its documentation (`dot settings` prints it); the function validates
  the value and expands it into what the system needs. Tap-to-click, for
  example, is three keys.
- **src/lib/** is the only code that reads or changes the system (`defaults`,
  `scutil`, `git`, `brew`, `ssh`, `gh`, `op`, `link`, `file`, `keys`), and it's
  where `check` and `apply` differ.

The engine is POSIX shell plus tools that ship with macOS and git from the
Command Line Tools, so it runs right after the installer.

## Commands

Each command is a file, `src/commands/dot-<name>`, and `dot` only finds and
runs it. A command's header is its documentation:

    #!/bin/sh
    # Summary: Clone a GitHub repo into ~/code/<owner>/<repo>
    # Usage: dot clone <repo>
    # Group: repos
    #
    # A description, then sections such as FLAGS and EXAMPLES.

`dot --help` lists commands by group (`core`, `repos`, `additional`; `hidden`
ones aren't listed), and `dot <command> --help` prints the header. A group
of subcommands, such as `dot conf backup`, is `dot-conf-backup`. Completion
comes from the same files, so a new command is one new file.

## Files in your home folder

- **config/home/** mirrors `~`. `config/home/.config/zed/settings.json` is
  linked to `~/.config/zed/settings.json`, so an app that edits its settings
  writes into the repo and `git diff` shows the change. If a file is already
  there, `apply` keeps it as `<file>.backup`.
- **Shared files** such as `~/.zshrc` and `~/.ssh/config` are never owned by
  the repo: `dot` keeps one marked block in them and leaves the rest to you
  and your tools.

## Personal values

`dot.conf` holds everything personal and isn't in git; `dot.conf.example` is
its public template. Config files refer to values as `$name`, so a fork
changes one file, not the config.

## Adding a setting

1. Find how macOS stores it (for example, `defaults read` before and after
   changing it in System Settings).
2. Add a function `<topic>_<setting>()` to `src/settings/<topic>.sh`, with a
   comment giving its syntax and values (`# dock visibility <always|hidden>`).
   It validates the input and calls `src/lib/` functions.
3. Add its line to a file in `config/`, and a row to [settings.md](settings.md).
4. Try it with `dot check <file>`, then `dot apply <file>`.

[AGENTS.md](../AGENTS.md) has the exact conventions.
