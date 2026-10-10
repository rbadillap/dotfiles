# dot

Your Mac, as code. Set it up from plain text, keep it that way, and work on
your projects.

```sh
# config/dock.conf
dock visibility hidden

# config/trackpad.conf
trackpad tap-to-click true
```

`dot check` shows what differs from the Mac and changes nothing; `dot apply`
fixes only that. `dot clone` puts every repository at `~/code/<owner>/<repo>`,
and `dot secret` keeps project secrets in 1Password, never on disk. The
engine is POSIX shell plus the tools macOS already has, and it's built for
coding agents too ([AGENTS.md](AGENTS.md)).

## Install

On a clean Mac (it shows its plan and asks before changing anything):

```sh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/rbadillap/dotfiles/main/install.sh)"
```

To make the choices yours, fork it and run the same command with
`DOTFILES_REPO=<you>/dotfiles`. Step by step: [Install](docs/02-get-started/01-install.mdx). Everything else:
[the docs](docs/index.mdx).

## Agents

Coding agents in your other projects (Claude Code, Codex, Cursor…) learn to
use `dot` from its [skill](skills/dot/SKILL.md):

```sh
npx skills add rbadillap/dotfiles --skill dot --global
```

More in [Agents](docs/06-agents/index.mdx).

## License

[MIT](LICENSE): fork it and make it yours.
