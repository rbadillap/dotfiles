# Backups of files that aren't in git.

# backup dot-conf <1password>   dot.conf is saved in 1Password as the Document
# "dotfiles: dot.conf", in your personal vault. install.sh can restore it on a
# new Mac. check says when dot.conf changed since the last backup.
backup_dot_conf() {
  [ "$1" = 1password ] || { fail "backup dot-conf: only '1password' is supported, got '$1'"; return; }
  op_document "dotfiles: dot.conf" "$DOT_ROOT/dot.conf"
}
