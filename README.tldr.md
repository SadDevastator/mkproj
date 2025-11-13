% mkproj(1)

NAME
    mkproj - small project scaffolding helper (templates + dependency metadata)

SYNOPSIS
    mkproj create <project-name> <template-name> [--auto-install] [--git] [--code|-C] [--dir <path>] [--update]
    mkproj add-template <source-folder|-> <template-name> [--script <script-path>] [--dependencies "k=v[,k2=v2,...]"] [--force]
    mkproj remove-template <template-name> [--force]
    mkproj update-dependancies <template-name> "k=v[,k2=v2,...]"
    mkproj list-templates
    mkproj update-templates
    mkproj update

TL;DR
    Create a new project from bundled or user templates:

    ```bash
    mkproj create myapp C
    mkproj create mylib Rust --auto-install --git
    ```

    Add or remove templates quickly:

    ```bash
    mkproj add-template ./my-template mytmpl
    mkproj add-template - scripttmpl --script ./create.sh
    mkproj remove-template mytmpl --force
    ```

DESCRIPTION
    `mkproj` manages a set of templates and per-template configuration modules. Templates live in
    `~/.config/mkproj/templates/` (user) or `templates/` bundled with the script. Per-template
    dependency metadata and hooks live in `~/.config/mkproj/config/` as shell modules (preferred),
    and legacy `<TEMPLATE>.conf` files are supported as a fallback.

COMMANDS
    create
        Scaffold a project from a template. The tool will copy template files, substitute
        `{{PROJECT_NAME}}`, and run a per-template hook if present (`mkproj_create_<template>`),
        or a `create.sh` inside the template via `$SHELL`.

    add-template
        Copy a folder into the user templates dir or create a script-only template with `-`.
        Use `--dependencies` to write dependency mappings and `--force` to overwrite without prompting.

    remove-template
        Remove a user template and its dependency/config file. Use `--force` to skip confirmation.

    update-dependancies
        Update the legacy dependency `.conf` for a template (keeps backward compatibility).

    list-templates
        List available user and bundled templates.

    update-templates
        Update user templates from a git repo, or seed bundled templates. If `MKPROJ_TEMPLATES_REPO`
        is set it will attempt to clone that repo into your templates directory.

    update
        Update the `mkproj` script itself (git pull when installed from a checkout, or reinstall
        from the default repo when installed as a script).

EXAMPLES
    Create a new project named `hello` from the `C` template:

    ```bash
    mkproj create hello C
    ```

    Add a script-only template and scaffold from it:

    ```bash
    mkproj add-template - myscript --script ./create_myscript.sh
    mkproj create p1 myscript
    ```

NOTES
    - Config/module lookup is case-insensitive: `Rust`, `rust`, and `RUST` match the same module.
    - Bundled modules are in the repository `config/` and `templates/` directories and will be
      copied to `~/.config/mkproj/` by the installer when first run.
    - The tool sources per-template shell modules; only place trusted modules in your config dir.

AUTHOR
    Developed by SadDevastator. See the project repository for contributions and licensing.

LICENSE
    MIT — see the `LICENSE` file in the repository.
