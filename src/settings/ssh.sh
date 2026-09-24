# SSH settings.

# ssh agent <1password>   SSH gets keys from 1Password's agent; they never touch disk
ssh_agent() {
  [ "$1" = 1password ] || { fail "ssh agent: only '1password' is supported, got '$1'"; return; }
  file_block "$HOME/.ssh/config" 600 "Host *
	IdentityAgent \"~/Library/Group Containers/2BUA8C4S2C.com.1password/t/agent.sock\""
}
