# The live copy: what ~/.zshrc, the links into ~ and the gh and vercel shims
# run. A git worktree of this repo at ~/.local/share/dotfiles/live, checked
# out (detached) at origin's main branch, so a branch checked out in the
# working copy runs nowhere. `dot update` creates it and moves it. Sourced by
# dot.

DOT_LIVE=$HOME/.local/share/dotfiles/live

# live_repo: the working copy (the repo's main worktree), whether dot runs
# from it, from a branch's worktree or from the live copy.
live_repo() {
  common=$(git -C "$DOT_ROOT" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || return 1
  dirname "$common"
}

# live_target <repo>: the commit of origin's main branch, as last fetched.
live_target() {
  git -C "$1" rev-parse -q --verify 'refs/remotes/origin/main^{commit}'
}

# live_exists: the live copy is a worktree of this repo.
live_exists() {
  [ -e "$DOT_LIVE/.git" ] || return 1
  have=$(git -C "$DOT_LIVE" rev-parse --path-format=absolute --git-common-dir 2>/dev/null) || return 1
  [ "$have" = "$(git -C "$DOT_ROOT" rev-parse --path-format=absolute --git-common-dir 2>/dev/null)" ]
}

# live_changed: the files changed in the live copy (an app writing its
# settings through a link, say), comma-separated; nothing when it's clean.
live_changed() {
  git -C "$DOT_LIVE" status --porcelain --untracked-files=all | cut -c4- | paste -sd, - | sed 's/,/, /g'
}

# live_copy: check that the live copy exists and sits at origin's main. It
# never moves it: `dot update` does, outside apply, since dot itself may be
# running from it.
live_copy() {
  live_exists || { fail "no live copy at ~/.local/share/dotfiles/live: run dot update"; return 0; }
  repo=$(live_repo) || { fail "live copy: can't find the repo"; return 0; }
  want=$(live_target "$repo") || { fail "live copy: the repo has no origin/main; run dot update"; return 0; }
  have=$(git -C "$DOT_LIVE" rev-parse HEAD)
  changes=$(live_changed)
  [ -z "$changes" ] || note "changed in the live copy (by an app, say): $changes; move them into the repo, since dot update won't overwrite them"
  [ "$have" = "$want" ] && return 0
  fail "the live copy is at $(git -C "$DOT_LIVE" rev-parse --short HEAD), origin/main at $(git -C "$repo" rev-parse --short "$want"): run dot update"
}
