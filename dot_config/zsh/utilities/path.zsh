# <ID> Path management utilities

# Prepend directory to PATH if it exists and isn't already in PATH
function prepend_path() {
    local dir="$1"
    [[ -d "$dir" ]] || return 1
    [[ ":$PATH:" == *":$dir:"* ]] && return 0
    export PATH="$dir:$PATH"
}

# Append directory to PATH if it exists and isn't already in PATH
function append_path() {
    local dir="$1"
    [[ -d "$dir" ]] || return 1
    [[ ":$PATH:" == *":$dir:"* ]] && return 0
    export PATH="$PATH:$dir"
}

# Remove directory from PATH
function remove_path() {
    local dir="$1"
    PATH="${PATH/#$dir:/}"      # Remove from start
    PATH="${PATH/%:$dir/}"      # Remove from end
    PATH="${PATH//:$dir:/:}"    # Remove from middle
    export PATH
}

