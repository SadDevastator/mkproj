# mkproj

> Scaffold projects from templates and per-template hooks.
> More information: <https://github.com/SadDevastator/mkproj>.

- Create a project from a template in the current directory:

`mkproj create {{name}} {{C|Rust|Python|Go|Flutter|TypeScript|JavaScript|Web}}`

- Create a project from a template variant:

`mkproj create {{name}} {{rust:lib|python:package|flutter:plugin}}`

- Create a project from any `bun create` template:

`mkproj create {{name}} bun:{{astro|vite|next-app|hono|elysia}}`

- Pass arguments to the underlying tool after `--`:

`mkproj create {{name}} web -- {{--template minimal --yes}}`

- Create a project in a specific directory, initialize git, and open VS Code:

`mkproj create {{name}} {{template}} --dir {{path/to/parent}} --git --code`

- Add a folder as a template:

`mkproj add-template {{path/to/folder}} {{template_name}}`

- List available templates:

`mkproj list-templates`

- Print the completion script for a shell:

`mkproj completions {{zsh|fish}}`
