# 1Password: SSH keys, signing and identities

1Password holds every secret this setup needs: SSH keys and API tokens. The
private key never leaves 1Password; it's used after Touch ID. Every item this
setup creates or uses (not your logins) is tagged `dotfiles`, so
`op item list --tags dotfiles` shows them all.

One SSH key does two jobs:

- **Authentication:** `git push` and `git pull` to GitHub.
- **Commit signing:** GitHub shows your commits as *Verified*.

The app (`config/apps.sh`) and its CLI, `op` (`config/packages.sh`), come
from `./dot apply`. The first three steps below are manual because they
involve your account.

## 1. Sign in

Open 1Password and sign in.

## 2. Turn on the developer features

In **Settings → Developer**, turn on:

- **Use the SSH agent**: SSH and git get keys from 1Password.
- **Integrate with 1Password CLI**: `op` uses the app's session and Touch ID.

If 1Password offers to update `~/.ssh/config`, either answer works; step 4
adds the same block if it's missing. To check:

    op vault list    # Touch ID, then your vaults
    ls ~/Library/Group\ Containers/2BUA8C4S2C.com.1password/t/agent.sock

The second command must print the path: that file is the agent's socket.

## 3. Create an SSH key

An **Ed25519** key, in your **built-in personal vault**: "Personal" on
individual and family accounts, "Private" on business ones. By default the SSH
agent only offers keys from that vault, and `op` uses it when no `--vault` is
given. Tag the key `dotfiles`, like every item this setup uses. One key per
Mac is fine; GitHub accepts several.

- **In the app:** *+ New Item → SSH Key → Add Private Key → Generate a New
  Key → Ed25519*. Title it `GitHub` and add the tag `dotfiles`.
- **In the terminal:**

      op item create --category "SSH Key" --title "GitHub" --tags dotfiles --ssh-generate-key ed25519

  The CLI can't edit SSH keys yet, so to tag an existing key, edit it in the
  app.

## 4. Use the key

Log in to GitHub first: [auth/github.md](auth/github.md). Then, in
`dot.conf`, `ssh_key` is the key's **title** in 1Password, and `github_user`
your GitHub username:

    ssh_key=GitHub
    github_user=rbadillap

    ./dot apply ssh       # ssh agent 1password
    ./dot apply git       # git signing-key $ssh_key
    ./dot apply github    # github ssh-key $github_user $ssh_key

- **`ssh agent 1password`** adds a `Host *` block to `~/.ssh/config` that
  points at the agent. The rest of the file stays yours.
- **`git signing-key`** makes git sign every commit and tag with the key
  (`op-ssh-sign`), and writes `~/.config/git/allowed_signers` so git can
  verify signatures locally.
- **`github ssh-key`** adds the public key to your GitHub account twice, as
  an authentication key and as a signing key, titled after the hostname
  (e.g. `ronny (1Password)`).

`./dot check` needs no Touch ID: the public key comes from the agent, and
GitHub's public key lists show what your account has. Signing a commit asks
for Touch ID, and so does `./dot apply github`, which adds keys through `gh`.

Check it:

    ssh -T git@github.com              # "Hi <you>! You've successfully authenticated"
    git log --show-signature -1        # in a repo with a new commit: Good "git" signature

Commits made before signing was on aren't signed. If they aren't pushed yet,
`git rebase --root --force-rebase` re-signs them.

## Identities per folder

The global identity (`git_name`, `git_email`) is the default. Repos under a
folder can use another name and email:

    # dot.conf
    site_dir=~/code/rbadillap/rbadillap
    site_git_name=Ronny Badilla
    site_git_email=info@ronnybadilla.com

    # config/git.sh
    git identity $site_dir $site_git_name $site_git_email

`./dot apply git` writes the identity to `~/.config/git/identities/<folder>`
and includes it for every repo under the folder (git's `includeIf gitdir`),
including repos cloned there later. To see which identity a repo uses:

    git -C <repo> var GIT_AUTHOR_IDENT

Signing uses the same key; the extra email joins `allowed_signers`. For
*Verified* on GitHub, the email must be verified on your account.

## Backup of dot.conf

`dot.conf` isn't in git, so it's kept in 1Password as the Document
"dotfiles: dot.conf", tagged `dotfiles`, in your built-in personal vault:

    backup dot-conf 1password    # config/backup.sh

    ./dot apply backup           # uploads dot.conf (Touch ID)

`./dot check` tells you when `dot.conf` changed since the last backup,
without Touch ID: it compares the file with a record of the last upload,
kept in `~/.local/state/dotfiles/`.

`apply` replaces the backup with your current `dot.conf`, but a Mac that
hasn't restored or backed up yet never overwrites an existing backup: its
`dot.conf` could be the wizard's defaults. It stops and asks you to restore
first (or to delete the item, if you really mean to replace it).

On a new Mac, the installer's **restore** option downloads it. To restore by
hand:

    op document get "dotfiles: dot.conf" --out-file dot.conf
