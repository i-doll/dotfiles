# vim: ft=zsh
# Forge shell integration plugin.
#
# Captures the block that `forge zsh setup` injects into ~/.zshrc so that
# ~/.zshrc can stay managed by chezmoi. On every shell startup this plugin:
#
#   1. Checks ~/.zshrc for a new/updated `# >>> forge initialize >>>` block.
#   2. If one is found, copies its contents into the managed region below
#      (updating both the live target file and the chezmoi source, when
#      available) and strips it from ~/.zshrc.
#   3. Evaluates the managed block so forge is initialised for this shell.
#
# This means `forge zsh setup` (or `forge update`) can re-run freely — the
# plugin self-heals on the next shell and chezmoi never sees drift.

_forge_plugin_self_sync() {
    emulate -L zsh
    setopt local_options no_nomatch pipefail

    local self="$1"
    [[ -n $self && -f $self ]] || return 0

    local zshrc="${HOME}/.zshrc"
    local start_marker='# >>> forge initialize >>>'
    local end_marker='# <<< forge initialize <<<'
    local region_start='# --- forge-managed-begin ---'
    local region_end='# --- forge-managed-end ---'

    [[ -f $zshrc ]] || return 0
    grep -qxF -- "$start_marker" "$zshrc" || return 0
    grep -qxF -- "$end_marker"   "$zshrc" || return 0

    # Extract the forge block (inclusive of markers) from ~/.zshrc.
    local block
    block=$(awk -v s="$start_marker" -v e="$end_marker" '
        $0 == s { flag = 1 }
        flag    { print }
        $0 == e { flag = 0 }
    ' "$zshrc") || return 0
    [[ -n $block ]] || return 0

    # Figure out which files to rewrite. The file may be sourced directly or
    # via a zinit snippet cache, so we assemble the full set of locations that
    # all need to stay in sync:
    #   1. $self                         — the actually-sourced file.
    #   2. $canonical                    — ~/.config/zsh/tools/forge.zsh
    #                                      (the chezmoi target; differs from
    #                                      $self when sourced from zinit's
    #                                      snippet cache).
    #   3. chezmoi source-path of (2)    — so chezmoi itself doesn't drift.
    local canonical="${HOME}/.config/zsh/tools/forge.zsh"
    local -a targets=("$self")
    [[ $self != $canonical && -f $canonical ]] && targets+=("$canonical")
    if command -v chezmoi >/dev/null 2>&1; then
        local src
        src=$(chezmoi source-path "$canonical" 2>/dev/null)
        [[ -n $src && -f $src && ${targets[(Ie)$src]} -eq 0 ]] && targets+=("$src")
    fi

    # Write block to a tmp file so awk can read it (avoids newline issues with -v).
    local block_file
    block_file=$(mktemp) || return 1
    printf '%s\n' "$block" > "$block_file"

    local target tmp
    for target in $targets; do
        # Only rewrite targets that actually contain the managed region.
        grep -qxF -- "$region_start" "$target" || continue
        grep -qxF -- "$region_end"   "$target" || continue
        tmp=$(mktemp "${target}.forge.XXXXXX") || { rm -f "$block_file"; return 1; }
        awk -v rs="$region_start" -v re="$region_end" -v bf="$block_file" '
            BEGIN {
                while ((getline line < bf) > 0) {
                    block = block (block ? "\n" : "") line
                }
                close(bf)
            }
            $0 == rs { print; print block; skip = 1; next }
            $0 == re { skip = 0 }
            !skip    { print }
        ' "$target" > "$tmp" && mv "$tmp" "$target" || { rm -f "$tmp" "$block_file"; return 1; }
    done
    rm -f "$block_file"

    # Remove the block from ~/.zshrc so chezmoi stays clean.
    tmp=$(mktemp "${zshrc}.forge.XXXXXX") || return 1
    awk -v s="$start_marker" -v e="$end_marker" '
        $0 == s { flag = 1; next }
        flag && $0 == e { flag = 0; next }
        !flag { print }
    ' "$zshrc" > "$tmp" && mv "$tmp" "$zshrc" || { rm -f "$tmp"; return 1; }

    print -u2 -- "[forge.zsh] synced forge init block into ${self}"
}

_forge_plugin_self_sync "${${(%):-%x}:A}"
unfunction _forge_plugin_self_sync

# Portability guard: if the forge binary isn't installed on this machine,
# skip the managed block entirely. This keeps the dotfile portable and
# prevents "command not found: forge" from leaking into zsh init output
# (which would otherwise trip Powerlevel10k's instant-prompt warning).
# Placed OUTSIDE the `--- forge-managed-* ---` markers so `forge zsh setup`
# and the self-sync above never overwrite it.
if ! command -v forge >/dev/null 2>&1; then
    return 0
fi

# --- forge-managed-begin ---
# >>> forge initialize >>>
# !! Contents within this block are managed by 'forge zsh setup' !!
# !! Do not edit manually - changes will be overwritten !!

# Add required zsh plugins if not already present
if [[ ! " ${plugins[@]} " =~ " zsh-autosuggestions " ]]; then
    plugins+=(zsh-autosuggestions)
fi
if [[ ! " ${plugins[@]} " =~ " zsh-syntax-highlighting " ]]; then
    plugins+=(zsh-syntax-highlighting)
fi

# Load forge shell plugin (commands, completions, keybindings) if not already loaded
if [[ -z "$_FORGE_PLUGIN_LOADED" ]]; then
    eval "$(forge zsh plugin)"
fi

# Load forge shell theme (prompt with AI context) if not already loaded
if [[ -z "$_FORGE_THEME_LOADED" ]]; then
    eval "$(forge zsh theme)"
fi
# <<< forge initialize <<<
# --- forge-managed-end ---
