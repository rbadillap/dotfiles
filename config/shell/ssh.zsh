# SSH_AUTH_SOCK points at 1Password's SSH agent (config/ssh.conf), so tools that
# ask the agent directly (ssh-add, agent forwarding) see its keys. Skipped when
# the socket doesn't exist, so a Mac without the agent keeps macOS's.
sock="$HOME/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock"
[[ -S $sock ]] && export SSH_AUTH_SOCK=$sock
unset sock
