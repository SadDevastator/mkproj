#!/usr/bin/env bash

# Flutter projects via flutter create. The variant is the --template value:
#   flutter (app, default), flutter:package, flutter:plugin, flutter:module, flutter:skeleton, ...
# Args after `--` are forwarded, e.g. `-- --org com.example --platforms android,ios`.

declare -g -A DEPS_FLUTTER
DEPS_FLUTTER[flutter]="flutter"

mkproj_create_flutter() {
    local name="$1" dest="$2" variant="$3"
    shift 3
    require_cmd flutter || return 1

    # Dart package names must be lowercase_with_underscores.
    local pkg="${name,,}"
    pkg="${pkg//[^a-z0-9_]/_}"
    [[ "$pkg" =~ ^[a-z] ]] || pkg="app_$pkg"

    local -a flags=(--project-name "$pkg")
    [[ -n "$variant" ]] && flags+=(--template "$variant")
    flutter create "${flags[@]}" "$@" "$dest"
}

mkproj_update_flutter() {
    local dest="$2"
    require_cmd flutter || return 1
    (cd "$dest" && flutter pub get)
}
