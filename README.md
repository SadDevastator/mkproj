mkproj
======

mkproj is a small project scaffolding helper that manages language templates and dependency metadata.

Usage
-----

- Create a project from a template:
```bash
mkproj create <project-name> <template-name> [--auto-install] [--git] [--code|-C] [--dir <path>]
```

- Add a template (copies a folder into the local templates dir):
```bash
mkproj add-template <source-folder> <template-name> [--dependencies "k=v[,k2=v2,...]"]
```

- Remove a template:
```bash
mkproj remove-template <template-name>
```

- Update a template's dependency mapping:
```bash
mkproj update-dependancies <template-name> "k=v[,k2=v2,...]"
```

- List available templates:
```bash
mkproj list-templates
```

- Pull updates for user templates (if templates are a git repo):
```bash
mkproj update-templates
```

Installation
------------

To install into your user bin directory run the provided installer:

Clone the repo and run the installer locally
```bash
# replace bash with your shell if you are using a different one
git clone https://github.com/SadDevastator/mkproj.git /tmp/mkproj && bash /tmp/mkproj/install.sh
```

Or run the installer directly
```bash
# replace bash with your shell if you are using a different one
bash -c "$(curl -fsSL https://raw.githubusercontent.com/SadDevastator/mkproj/master/install.sh)"
```

The installer copies the `mkproj` script to `~/.local/bin/mkproj`, makes it executable and appends `~/.local/bin` to common shell rc files (`.profile`, `.bashrc`, `.zshrc`, and Fish config) if needed.

---------------------------

- Templates are stored in `~/.config/mkproj/templates/`.
- Per-template dependency mappings live in `~/.config/mkproj/config/` as files named `<TEMPLATE>.conf` (upper-cased internally).
- Bundled templates shipped with the repository live under the `templates/` directory adjacent to the `mkproj` script and are used when no user template exists.

Notes
-----

- The tool looks for `create.sh` in a created project and runs it (if executable) after copying the template.
- For Rust projects, if `cargo` is not installed the script can offer to run the official rustup installer.

License
-------

This project is licensed under the MIT License — see the `LICENSE` file for details.