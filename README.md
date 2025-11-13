# mkproj

mkproj is a minimal, script-based project scaffolding helper. It manages templates, per-template
dependency metadata, and simple hook scripts so you can quickly scaffold projects for C, Rust,
or any language you add a template for.

This repository contains:
- `mkproj` — the main CLI script
- `install.sh` — installer that seeds user config and adds `~/.local/bin` to PATH
- `templates/` — bundled templates used as fallbacks
- `config/` — bundled per-template config modules for hooks and dependency mappings

Key features
- Modular per-template config modules (`~/.config/mkproj/config/*.sh`) that can declare dependency
  mappings and `mkproj_create_<template>` / `mkproj_update_<template>` hook functions.
- Templates are stored under `~/.config/mkproj/templates/` for user edits, and the repo provides
  bundled templates in `templates/`.
- `add-template` / `remove-template` / `list-templates` commands to manage templates locally.
- `create` will copy template files, substitute `{{PROJECT_NAME}}`, and run create/update hooks.

Quickstart
1. Install the tool (user-local):

```bash
git clone https://github.com/SadDevastator/mkproj.git /tmp/mkproj
$SHELL /tmp/mkproj/install.sh
```
Or run the installer directly
```bash
$SHELL -c "$(curl -fsSL https://raw.githubusercontent.com/SadDevastator/mkproj/master/install.sh)"
```
2. Create a project from the bundled C template:

```bash
mkproj create hello C
```

3. Add a script-only template and use it:

```bash
mkproj add-template - myscript --script ./create_myscript.sh
mkproj create example myscript
```

Commands (summary)
- `mkproj create <name> <template> [--auto-install] [--git] [--code|-C] [--dir <path>] [--update]`
- `mkproj add-template <source-folder|-> <template-name> [--script <script-path>] [--dependencies "k=v,..."] [--force]`
- `mkproj remove-template <template-name> [--force]`
- `mkproj update-dependancies <template-name> "k=v,..."`
- `mkproj list-templates`
- `mkproj update-templates` (pulls templates or seeds bundled templates)
- `mkproj update` (self-update)

Design notes
- Per-template config modules are sourced into the script (trusted content). Prefer using the
  `$HOME/.config/mkproj/config/YourTemplate.sh` modules which can declare an associative array
  `DEPS_<TEMPLATE>` and hook functions.
- The tool prefers `.sh` modules and falls back to legacy `.conf` files for dependency mappings.
- The installer tries to reload the user's shell environment (best-effort) after installing.

Contributing
- Add templates under `templates/` and config modules under `config/` for bundled support.
- For user templates, use `mkproj add-template` to copy folders into `~/.config/mkproj/templates/`.

Security
- Because the tool sources shell modules from `~/.config/mkproj/config/`, only place trusted
  files there. Treat configuration files like executable content.

License
This project is licensed under the MIT License — see the `LICENSE` file for details.
