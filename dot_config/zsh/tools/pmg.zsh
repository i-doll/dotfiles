if [ -d "${HOME}/.pmg" ]; then
    # PMG source aliases — remove by running `pmg setup remove`
    [ -f "${HOME}/.pmg.rc" ] && source "${HOME}/.pmg.rc"

    # PMG shims — remove by running `pmg setup remove`
    export PATH="${HOME}/.pmg/bin:${PATH}"
fi
