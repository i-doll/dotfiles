# vim: ft=zsh

# --- Key bindings (Home / End / Delete) ---
typeset -g -A key
key[Home]="${terminfo[khome]}"
key[End]="${terminfo[kend]}"
key[Delete]="${terminfo[kdch1]}"
key[Insert]="${terminfo[kich1]}"

[[ -n "${key[Home]}"   ]] && bindkey -- "${key[Home]}"   beginning-of-line
[[ -n "${key[End]}"    ]] && bindkey -- "${key[End]}"    end-of-line
[[ -n "${key[Delete]}" ]] && bindkey -- "${key[Delete]}" delete-char
[[ -n "${key[Insert]}" ]] && bindkey -- "${key[Insert]}" overwrite-mode

# Fallbacks for terminals that don't populate terminfo correctly
bindkey '^[[H'  beginning-of-line
bindkey '^[OH'  beginning-of-line
bindkey '^[[F'  end-of-line
bindkey '^[OF'  end-of-line
bindkey '^[[3~' delete-char
