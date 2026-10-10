#!/usr/bin/env bash

# Python projects via uv. The variant is passed to `uv init` as a flag:
#   python (app, default), python:lib, python:package, python:script, python:bare
# Args after `--` are forwarded to uv init, e.g. `-- --python 3.12`.

declare -g -A DEPS_PYTHON
DEPS_PYTHON[uv]="uv"

mkproj_create_python() {
    local name="$1" dest="$2" variant="$3"
    shift 3
    require_cmd uv "curl -LsSf https://astral.sh/uv/install.sh | sh" "$HOME/.local/bin" || return 1

    local -a flags=()
    [[ -n "$variant" ]] && flags+=("--$variant")
    uv init --name "$name" "${flags[@]}" "$@" "$dest"
}

mkproj_update_python() {
    local dest="$2"
    require_cmd uv || return 1
    (cd "$dest" && uv sync)
}
