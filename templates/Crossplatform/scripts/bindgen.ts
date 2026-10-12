// Usage: bun run bindgen [kotlin|swift|python ...]
// Builds the core cdylib and generates UniFFI bindings into bindings/<language>.
import { $ } from "bun";

const languages = Bun.argv.slice(2);
if (languages.length === 0) languages.push("kotlin", "swift", "python");

const ext = { darwin: "dylib", win32: "dll" }[process.platform] ?? "so";
const prefix = process.platform === "win32" ? "" : "lib";
const lib = `target/debug/${prefix}app_core.${ext}`;

await $`cargo build -p app_core`;
for (const language of languages) {
  await $`cargo run -p uniffi-bindgen -- generate --library ${lib} --language ${language} --out-dir bindings/${language}`;
}
