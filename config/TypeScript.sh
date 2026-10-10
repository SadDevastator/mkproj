#!/usr/bin/env bash

# TypeScript projects via bun (bun init).
# typescript:<template> behaves like bun:<template>.

source_config_module bun || { err "Bun config module not found"; return 1; }

declare -g -A DEPS_TYPESCRIPT
DEPS_TYPESCRIPT[bun]="bun"

mkproj_create_typescript() {
    mkproj_create_bun "$1" "$2" "${3:-ts}" "${@:4}"
}

mkproj_update_typescript() {
    mkproj_update_bun "$@"
}
