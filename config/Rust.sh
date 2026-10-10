#!/usr/bin/env bash

declare -g -A DEPS_RUST
DEPS_RUST[cargo]="cargo"

# Variant is passed to `cargo new` as a flag, e.g. rust:lib -> --lib
mkproj_create_rust() {
    local name="$1" dest="$2" variant="$3"
    shift 3
    require_cmd cargo "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh" "$HOME/.cargo/bin" || return 1

    local -a flags=()
    [[ -n "$variant" ]] && flags+=("--$variant")
    cargo new --name "$name" "${flags[@]}" "$@" "$dest"
}

mkproj_update_rust() {
    local dest="$2"
    require_cmd cargo || return 1
    (cd "$dest" && cargo update)
}
