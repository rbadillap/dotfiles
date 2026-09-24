# Languages and tool versions

[mise](https://mise.jdx.dev) manages the versions of Node, pnpm, Bun, Python, uv
and other tools, globally and per project.

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
| Python | 3.13     |
| uv     | latest   |

`mise use -g <tool>@<version>` changes it, and since the file is linked, the
change lands in the repo: commit it or discard it. `dot check` reports tools
from the config that aren't installed yet.

## Per project

Entering a folder activates its versions; leaving it goes back to the global
ones. mise reads, in order of preference:

- `mise.toml`, its own file: `mise use node@22` in a project writes it.
- `.tool-versions`, asdf's file.
- `.nvmrc`, `.node-version` and `.python-version`, since
  `idiomatic_version_file_enable_tools` includes `node` and `python` in the
  global config. Add other tools there to read their files
  (`.terraform-version`).

A version a project asks for that isn't installed yet is installed the first
time you run it.

## Everyday commands

| Command                        | Does                                                  |
|--------------------------------|-------------------------------------------------------|
| `mise ls --current`            | versions active in this folder, and which file set each |
| `mise use node@22`             | pin a version in this project (writes `mise.toml`)    |
| `mise use -g node@24`          | change a global version (edits the linked config)     |
| `mise install`                 | install what this folder's files ask for             |
| `mise upgrade`                 | update installed tools within their pinned ranges     |
| `mise trust`                   | allow a project's `mise.toml` (see below)             |
| `mise doctor`                  | check mise's own setup                                |

**Trust.** A `mise.toml` can set environment variables and run tasks, so mise
only reads one from a folder you trust. The first time you enter a cloned
project that has one, mise asks you to run `mise trust`. Version files such
as `.nvmrc` don't need it.

## pnpm and Bun

Both are installed, and each project uses the one its lockfile shows
(`pnpm-lock.yaml` or `bun.lock`). pnpm switches by itself to the version in a
project's `"packageManager"` field; a project can pin Bun in its `mise.toml`.

## Python and uv

mise installs Python; [uv](https://docs.astral.sh/uv/) handles each
project's dependencies and virtual environment.

    uv init my-app      # a new project
    uv add httpx        # add a dependency (creates .venv and uv.lock)
    uv sync             # install what uv.lock lists, e.g. after cloning
    uv run main.py      # run inside the project's environment

- **The .venv activates itself.** In a folder with `uv.lock`, mise activates
  its `.venv` when you enter and deactivates it when you leave
  (`python.uv_venv_auto = "source"`); `python` and installed tools are the
  project's. Run `uv sync` once after cloning to create it.
- **One owner for Python versions.** uv uses the Python mise installed and
  never downloads its own (`UV_PYTHON_PREFERENCE` and `UV_PYTHON_DOWNLOADS` in
  the config's `[env]`). A project that asks for another version in
  `.python-version` gets it from mise: run `mise install` in that folder.
