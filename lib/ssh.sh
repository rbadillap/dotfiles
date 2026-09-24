# SSH keys served by 1Password's agent. Sourced by dot.

OP_SSH_SOCK="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"

# ssh_pubkey <title>: prints the public key 1Password's agent serves under that
# item title. Listing public keys needs no Touch ID. Not a check by itself.
ssh_pubkey() {
  SSH_AUTH_SOCK=$OP_SSH_SOCK ssh-add -L 2>/dev/null |
    awk -v t="$1" '{ k = $1 " " $2; $1 = $2 = ""; sub(/^ +/, ""); if ($0 == t) { print k; exit } }'
}
