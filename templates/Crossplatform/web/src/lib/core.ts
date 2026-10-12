import { invoke } from "@tauri-apps/api/core";

const inTauri = "__TAURI_INTERNALS__" in globalThis;

// Native: Tauri -> Rust core. Browser/PWA: replace the fallback with a wasm build of the core.
export const greet = (name: string): Promise<string> =>
  inTauri ? invoke<string>("greet", { name }) : Promise.resolve(`Hello, ${name}, from the web!`);
