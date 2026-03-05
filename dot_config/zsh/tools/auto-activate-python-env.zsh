add-zsh-hook chpwd function() {
    if [[ -d .venv ]]; then
        source .venv/bin/activate
    fi
}