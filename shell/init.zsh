# Entry point for zsh, loaded from ~/.zshrc by a block that `./dot apply shell`
# adds. ~/.zshrc stays yours: tools may append to it, and dot never rewrites it.
# Each file here covers one topic; they load in this order.

for topic in path op editor prompt; do
  source "${0:A:h}/$topic.zsh"
done
unset topic
