#!/usr/bin/env bash

# Web projects via bun. Default is Astro (bun create astro).
#   web:react                 -> bun init --react
#   web:tailwind / web:shadcn -> bun init --react=tailwind / --react=shadcn
#   web:<anything else>       -> bun create <anything else> (web:vite, web:next-app, ...)

source_config_module bun || { err "Bun config module not found"; return 1; }

declare -g -A DEPS_WEB
DEPS_WEB[bun]="bun"

mkproj_create_web() {
    local variant="${3:-astro}"
    case "${variant,,}" in
        tailwind|shadcn) variant="react=${variant,,}" ;;
    esac
    mkproj_create_bun "$1" "$2" "$variant" "${@:4}"
}

mkproj_update_web() {
    mkproj_update_bun "$@"
}
