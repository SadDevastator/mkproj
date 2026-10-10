#!/usr/bin/env bash

# Bun projects. The variant picks what gets generated:
#   bun                      -> bun init (TypeScript)
#   bun:js                   -> bun init, converted to JavaScript
#   bun:react[=tailwind|=shadcn] -> bun init --react
#   bun:<anything else>      -> bun create <anything else>  (e.g. bun:astro, bun:vite,
#                               bun:next-app, bun:hono, bun:elysia, bun:<github-user>/<repo>)
# Args after `--` are forwarded to bun init / bun create.

declare -g -A DEPS_BUN
DEPS_BUN[bun]="bun"

_mkproj_require_bun() {
    require_cmd bun "curl -fsSL https://bun.sh/install | bash" "${BUN_INSTALL:-$HOME/.bun}/bin"
}

# Set package.json "name" (bun's React template hardcodes its own).
_mkproj_bun_set_name() {
    local name="$1" dest="$2"
    [[ -f "$dest/package.json" ]] || return 0
    (cd "$dest" && bun -e '
        const f = "package.json", pkg = await Bun.file(f).json();
        pkg.name = process.argv[1];
        await Bun.write(f, JSON.stringify(pkg, null, 2) + "\n");
    ' "$name")
}

_mkproj_bun_to_js() {
    local dest="$1"
    (
        cd "$dest" || exit 1
        [[ -f index.ts ]] && mv index.ts index.js
        [[ -f tsconfig.json ]] && mv tsconfig.json jsconfig.json
        [[ -f README.md ]] && sed -i 's/index\.ts/index.js/g' README.md
        bun -e '
            const f = "package.json", pkg = await Bun.file(f).json();
            if (pkg.module === "index.ts") pkg.module = "index.js";
            delete pkg.scripts?.typecheck;
            if (pkg.scripts && !Object.keys(pkg.scripts).length) delete pkg.scripts;
            delete pkg.peerDependencies?.typescript;
            if (pkg.peerDependencies && !Object.keys(pkg.peerDependencies).length) delete pkg.peerDependencies;
            await Bun.write(f, JSON.stringify(pkg, null, 2) + "\n");
        '
    )
}

mkproj_create_bun() {
    local name="$1" dest="$2" variant="$3"
    shift 3
    _mkproj_require_bun || return 1

    case "${variant,,}" in
        ""|ts|typescript)
            bun init -y "$@" "$dest"
            ;;
        js|javascript)
            bun init -y "$@" "$dest" && _mkproj_bun_to_js "$dest"
            ;;
        react|react=*)
            bun init -y "--${variant,,}" "$@" "$dest" && _mkproj_bun_set_name "$name" "$dest"
            ;;
        *)
            bun create "$variant" "$dest" "$@"
            ;;
    esac
}

mkproj_update_bun() {
    local dest="$2"
    _mkproj_require_bun || return 1
    (cd "$dest" && bun install)
}
