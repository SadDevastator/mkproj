#!/usr/bin/env bash

# JavaScript projects via bun (bun init, converted to JS).
# javascript:<template> behaves like bun:<template>.

source_config_module bun || { err "Bun config module not found"; return 1; }

declare -g -A DEPS_JAVASCRIPT
DEPS_JAVASCRIPT[bun]="bun"

mkproj_create_javascript() {
    mkproj_create_bun "$1" "$2" "${3:-js}" "${@:4}"
}

mkproj_update_javascript() {
    mkproj_update_bun "$@"
}
