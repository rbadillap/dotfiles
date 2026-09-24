# Languages and tool versions

[mise](https://mise.jdx.dev) manages the versions of Node, pnpm, Bun and
other tools, globally and per project.

    dot apply mise

This installs mise, links its global config, and installs every tool in it.
`config/shell/mise.zsh` activates mise in each terminal.

## Global versions

`config/home/.config/mise/config.toml`, linked to `~/.config/mise/config.toml`:

| Tool   | Version  |
|--------|----------|
| Node   | 24       |
| pnpm   | latest   |
| Bun    | latest   |

`mise use -g <tool>@<version>` changes it, and since the file is linked, the
change lands in the repo: commit it or discard it. `dot check` reports tools
from the config that aren't installed yet.

## Per project

Entering a folder activates its versions; leaving it goes back to the global
ones. mise reads, in order of preference:

- `mise.toml`, its own file: `mise use node@22` in a project writes it.
- `.tool-versions`, asdf's file.
- `.nvmrc` and `.node-version`, since `idiomatic_version_file_enable_tools`
  includes `node` in the global config. Add other tools there to read their
  files (`.python-version`, `.terraform-version`).

A version a project asks for that isn't installed yet is installed the first
time you run it.

## pnpm and Bun

Both are installed, and each project uses the one its lockfile shows
(`pnpm-lock.yaml` or `bun.lock`). pnpm switches by itself to the version in a
project's `"packageManager"` field; a project can pin Bun in its `mise.toml`.
