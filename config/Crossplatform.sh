#!/usr/bin/env bash

# Cross-platform app: Tauri 2 shell + Rust core (UniFFI) + Astro PWA, bun as package manager.
# templates/Crossplatform ships the whole project (web/ scaffold, app icons, bun.lock,
# Cargo.lock), so the default needs no generator, only `bun install`.
#   crossplatform        -> the bundled project
#   crossplatform:fresh  -> regenerate the Astro scaffold (`bun create astro`), the app icons
#                           (`bun tauri icon`) and both lockfiles with the latest tools.
#                           Needs network; args after `--` are forwarded to `bun create astro`.
declare -g -A DEPS_CROSSPLATFORM
DEPS_CROSSPLATFORM[bun]="bun"
DEPS_CROSSPLATFORM[cargo]="cargo"

_mkproj_crossplatform_fresh() {
    require_cmd cargo "curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh" "$HOME/.cargo/bin" || return 1

    # Keep the template's own web files; the rest of web/ comes from the Astro scaffold.
    mv web .bundled && rm -f bun.lock Cargo.lock || return 1
    bun create astro@latest web -- --template minimal --no-install --no-git --skip-houston --yes "$@" || return 1
    (cd web && bun add @tauri-apps/api) || return 1
    local f
    for f in astro.config.mjs public/icon.svg public/manifest.webmanifest public/sw.js src/lib/core.ts src/pages/index.astro; do
        mkdir -p "web/$(dirname "$f")" && cp ".bundled/$f" "web/$f" || return 1
    done
    rm -rf .bundled
    bun install || return 1
    bun tauri icon web/public/icon.svg || return 1
    cargo generate-lockfile
}

mkproj_create_crossplatform() {
    local name="$1" dest="$2" variant="$3"
    shift 3
    require_cmd bun "curl -fsSL https://bun.sh/install | bash" "${BUN_INSTALL:-$HOME/.bun}/bin" || return 1

    cd "$dest" || return 1
    case "${variant,,}" in
        "") ;;
        fresh) _mkproj_crossplatform_fresh "$@" || return 1 ;;
        *) err "Unknown Crossplatform variant '$variant' (use 'fresh' or none)."; return 1 ;;
    esac

    bun install || return 1
    info "Created cross-platform project: $dest"
    info "Linux needs the Tauri system dependencies: https://v2.tauri.app/start/prerequisites/"
}

mkproj_update_crossplatform() {
    local dest="$2"
    require_cmd bun || return 1
    (cd "$dest" && bun install)
}
