# {{PROJECT_NAME}}

Cross-platform workspace: a Rust core exposed through UniFFI, a Tauri 2 shell, and an Astro PWA frontend. Package manager is bun.

```
crates/core            Rust library (UniFFI proc-macros); add your logic here
crates/uniffi-bindgen  Bindings generator binary
src-tauri              Tauri app; calls the core directly as a Rust dependency
web                    Astro frontend; manifest + service worker make it a PWA in the browser (public/)
scripts/bindgen.ts     Generates Kotlin / Swift / Python bindings into bindings/
```

## Usage

```
bun install
bun run dev                    # Tauri desktop app with Astro dev server
bun run build                  # Tauri bundles
bun run web                    # PWA only, in the browser
bun run bindgen [kotlin swift python]
```

Linux needs the Tauri system dependencies (webkit2gtk, gtk3); see https://v2.tauri.app/start/prerequisites/.

## Adding functionality

1. Export from `crates/core/src/lib.rs` with `#[uniffi::export]`, `#[derive(uniffi::Record)]`, and so on.
2. Expose it to the UI with a `#[tauri::command]` in `src-tauri/src/lib.rs` and register it in `generate_handler!`.
3. Call it from `web/src/lib/core.ts`. The non-Tauri branch is the PWA fallback; swap it for a wasm build of the core if the PWA needs the same logic.

The icon `web/public/icon.svg` is the Rust logo from the simple-icons package, used unmodified. Replace it and run `bun tauri icon web/public/icon.svg` to regenerate app icons.
