# 1Password CLI plugins — shims that route tool auth (gh, aws, etc.) through op.
# `~/.config/op/plugins.sh` is generated per-machine by `op plugin init <tool>`,
# so source it only when present to stay portable across machines without it.
[ -f ~/.config/op/plugins.sh ] && source ~/.config/op/plugins.sh
