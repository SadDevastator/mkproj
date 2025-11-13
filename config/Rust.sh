#!/usr/bin/env bash

declare -g -A DEPS_RUST
DEPS_RUST[cargo]="cargo"

mkproj_create_rust() {
    local name="$1" target_dir="$2"
    if ! command -v cargo &>/dev/null; then
        warn "cargo not found."
        read -r -p "Install Rust toolchain now using rustup? (This will run: curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh) [Y/n]: " ans
        ans=${ans:-Y}
        if [[ "$ans" =~ ^[Yy] ]]; then
            info "Installing rustup and Rust toolchain..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh || { err "rustup install failed"; return 1; }
            if [[ -f "$HOME/.cargo/env" ]]; then
                . "$HOME/.cargo/env"
            fi
            if ! command -v cargo &>/dev/null; then
                err "cargo still not found after installation. Please restart your shell or add \$HOME/.cargo/bin to PATH and try again."
                return 1
            fi
        else
            err "cargo required to create Rust projects. Aborting."
            return 1
        fi
    fi

    (cd "$target_dir" && cargo new "$name")
}
