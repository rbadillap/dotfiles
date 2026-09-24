# Tools

`bin/` holds small commands for everyday work. `shell/path.zsh` puts it on
`PATH`, so they run from any folder. Each has `--help`.

| Command | Does                                                             |
|---------|------------------------------------------------------------------|
| `clone` | clones a GitHub repo into `~/code/<owner>/<repo>`                 |
| `fork`  | forks a repo to your account, clones it, adds `upstream`         |
| `dot`   | the settings CLI ([dot.md](dot.md)), available from anywhere     |

In zsh, `clone` and `fork` take you to the repo afterwards
(`shell/code.zsh`).

## clone

    clone vercel/next.js                     # ~/code/vercel/next.js
    clone https://github.com/shadcn-ui/ui    # URLs work too: ~/code/shadcn-ui/ui

- **Accepts** `owner/repo`, `github.com/owner/repo`, `https://github.com/…`
  (with `.git`, `/tree/…`, `?…` or `#…`), `git@github.com:…` and
  `ssh://git@github.com/…`. Other hosts are refused: every repo lives at
  `~/code/<owner>/<repo>`, mirroring GitHub.
- **Clones over SSH**, with your key from 1Password.
- **Uses GitHub's spelling** of the name, and follows renamed repos, when the
  repo is public: `clone OCTOCAT/hello-world` lands in `~/code/octocat/Hello-World`.
- **Already there?** It only prints the path.
- **Never overwrites.** It stops if the folder is another repo, or holds
  anything but a git repo; an empty folder is fine. A failed clone leaves no
  folder behind.

## fork

    fork vercel/next.js    # fork to your account, clone to ~/code/<you>/next.js

- Your fork is cloned as `origin`; the original becomes `upstream`, so
  `git fetch upstream` brings in its changes.
- **Already forked?** It reuses your fork, even if GitHub named it
  differently because the name was taken.
- **Your own repo?** It just clones it.
- It stops if the repo doesn't exist, you can't access it, forking is
  disabled, or an `upstream` remote already points elsewhere.
- Your username comes from `github_user` in `dot.conf`. Forking goes through
  `gh`, so it may ask for Touch ID.

## Output

Messages go to stderr; the only thing on stdout is the repo's path, on
success. That keeps them usable from scripts and agents:

    dir=$(clone vercel/next.js) && cd "$dir"

Exit codes: `0` done or already there, `1` failed, `2` bad usage.
