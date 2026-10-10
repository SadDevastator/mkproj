# mkproj

mkproj is a minimal, script-based project scaffolding helper. It manages
templates, per-template dependency metadata, and hook scripts so you can quickly
scaffold projects for C, Rust, Python, Go, Flutter, TypeScript/JavaScript/web
(via bun), or any language you add a template for.

This repository contains:

- `mkproj` — the main CLI script
- `install.sh` — installer that seeds user config, adds `~/.local/bin` to PATH,
  and sets up zsh/fish completions
- `templates/` — bundled templates used as fallbacks
- `config/` — bundled per-template config modules for hooks and dependency
  mappings

## Key features

- Modular per-template config modules (`~/.config/mkproj/config/*.sh`) that can
  declare dependency mappings and `mkproj_create_<template>` /
  `mkproj_update_<template>` hook functions.
- Templates are stored under `~/.config/mkproj/templates/` for user edits, and
  the repo provides bundled templates in `templates/`.
- `create` copies template files, substitutes `{{PROJECT_NAME}}`, and runs the
  template's create (or, with `--update`, update) hook.
- Template variants: `<template>:<variant>` passes the variant to the hook, so
  `bun:astro` runs `bun create astro`. Arguments after `--` are forwarded to the
  underlying tool.
- zsh and fish completions, including template names.

## Quickstart

1. Install the tool (user-local):

   ```bash
   git clone https://github.com/SadDevastator/mkproj.git /tmp/mkproj
   bash /tmp/mkproj/install.sh
   ```

   Or run the installer directly:

   ```bash
   bash -c "$(curl -fsSL https://raw.githubusercontent.com/SadDevastator/mkproj/master/install.sh)"
   ```

   The installer asks whether to append PATH and completion setup to your
   shell config files, or print the snippets so you can place them yourself
   (useful with a custom shell config). Set `MKPROJ_SHELL_SETUP=auto` or
   `MKPROJ_SHELL_SETUP=manual` to skip the prompt.

2. Create a project from the bundled C template:

   ```bash
   mkproj create hello C
   ```

3. Add a script-only template and use it:

   ```bash
   mkproj add-template - myscript --script ./create_myscript.sh
   mkproj create example myscript
   ```

## Bundled templates

- `C` — CMake project from `templates/C`.
- `Arduino` — sketch from `templates/Arduino`.
- `Rust` — `cargo new`. Variant is a flag: `rust:lib`.
- `Python` — `uv init`. Variant is a flag: `python:lib`, `python:package`,
  `python:script`.
- `Go` — `go mod init`, `main.go`, then `go generate`. Variant is the module
  path: `go:github.com/you/app`.
- `Flutter` — `flutter create`. Variant is the `--template`: `flutter:package`,
  `flutter:plugin`, `flutter:module`.
- `TypeScript` — `bun init`.
- `JavaScript` — `bun init`, converted to JavaScript.
- `Web` — `bun create astro`. Variants: `web:react`, `web:tailwind`,
  `web:shadcn` (`bun init --react`).
- `Bun` — `bun init`. Variants: `bun:js`, `bun:react`, `bun:react=tailwind`,
  `bun:react=shadcn`.

`Bun`, `TypeScript`, `JavaScript`, and `Web` also accept any `bun create`
template as the variant, without it being listed anywhere. That covers npm
`create-*` packages (`bun:astro`, `bun:vite`, `bun:next-app`, `bun:hono`,
`bun:elysia`, ...) and GitHub repos (`bun:user/repo`). Some of them prompt
interactively; pass their flags after `--` to skip prompts:

```bash
mkproj create site bun:astro -- --template minimal --yes
mkproj create api python -- --python 3.12
mkproj create app flutter -- --org com.example --platforms android,ios
```

Missing tools are reported when the hook runs. `--auto-install` installs
dependencies via your package manager, and hooks for `cargo`, `uv`, and `bun`
offer to run the official installer.

## Commands

```text
mkproj create <name> <template>[:<variant>] [--auto-install] [--git] [--code|-C]
              [--dir <path>] [--update] [-- <tool args>...]
mkproj add-template <source-folder|-> <template-name> [--script <script-path>]
                    [--dependencies "k=v,..."] [--force]
mkproj remove-template <template-name> [--force]
mkproj update-dependancies <template-name> "k=v,..."
mkproj list-templates
mkproj update-templates      # reinstall templates from the repo / bundled copy
mkproj update                # self-update via the installer
mkproj uninstall [--yes]     # remove mkproj, its shell setup, and optionally config
mkproj completions <zsh|fish>
```

## Shell completions

The installer writes `~/.config/mkproj/completions/_mkproj` and
`~/.config/fish/completions/mkproj.fish`. In manual mode, it prints the lines
instead. For zsh, either source the file after `compinit`:

```zsh
[[ -r "$HOME/.config/mkproj/completions/_mkproj" ]] && source "$HOME/.config/mkproj/completions/_mkproj"
```

or add the directory to `fpath` before `compinit` runs:

```zsh
fpath=("$HOME/.config/mkproj/completions" $fpath)
```

For fish:

```fish
mkproj completions fish > ~/.config/fish/completions/mkproj.fish
```

## Writing a config module

A module at `~/.config/mkproj/config/<Template>.sh` is sourced into mkproj and
can define:

```bash
declare -g -A DEPS_MYTEMPLATE
DEPS_MYTEMPLATE[cmd]="package-name"   # used by --auto-install

# $1 = project name, $2 = project dir, $3 = variant, $4... = args after `--`
# Runs from the parent directory; $2 may not exist yet.
mkproj_create_mytemplate() { ...; }
mkproj_update_mytemplate() { ...; }
```

Hooks can call mkproj's `info`, `success`, `warn`, `err`, and
`require_cmd <cmd> [installer-command] [bin-dir]` helpers. If a template
directory exists, its files are copied into the project dir before the hook
runs. Without a hook function, a `create.sh` / `update.sh` inside the project
runs instead.

## Design notes

- Per-template config modules are sourced into the script (trusted content).
  The tool prefers `.sh` modules and falls back to legacy `.conf` files for
  dependency mappings.
- Template and module lookup is case-insensitive.
- Re-running the installer updates bundled config modules, saving any changed
  copy as `<Template>.sh.bak`.

## Contributing

- Add templates under `templates/` and config modules under `config/` for
  bundled support.
- For user templates, use `mkproj add-template` to copy folders into
  `~/.config/mkproj/templates/`.

## Security

- Because the tool sources shell modules from `~/.config/mkproj/config/`, only
  place trusted files there. Treat configuration files like executable content.

## License

This project is licensed under the MIT License — see the `LICENSE` file for
details.
