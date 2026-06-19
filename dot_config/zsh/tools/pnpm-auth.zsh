# GitHub Packages auth for our own @i-doll/* packages (e.g. @i-doll/logger-sdk).
# Those resolve from npm.pkg.github.com and need NODE_AUTH_TOKEN. Rather than
# keep the token in the environment (or prompt 1Password on every shell), pull
# it from 1Password ONLY for install-type pnpm commands.
#
# pmg aliases `pnpm` -> `pmg pnpm` (see tools/pmg.zsh, sourced just before
# this), so we must load after it: drop the alias and replace it with a
# function that delegates back through `pmg pnpm`, injecting the token for the
# commands that actually fetch packages.
unalias pnpm 2>/dev/null

pnpm() {
    local -a runner
    if command -v pmg >/dev/null 2>&1; then
        runner=(pmg pnpm)   # preserve the pmg flow
    else
        runner=(command pnpm)
    fi

    case "$1" in
    add | install | i | update | up | dlx | create)
        if command -v op >/dev/null 2>&1; then
            NODE_AUTH_TOKEN="$(op read 'op://Thea/Github NPM/credential' --account my.1password.com)" \
                "${runner[@]}" "$@"
        else
            "${runner[@]}" "$@"
        fi
        ;;
    *)
        "${runner[@]}" "$@"
        ;;
    esac
}
