#!/usr/bin/env bash

# Per-template config module for Arduino templates
# Declares dependency mapping and a create hook that renames the .ino file

declare -g -A DEPS_ARDUINO
DEPS_ARDUINO["arduino-cli"]="arduino-cli"

mkproj_create_arduino() {
    # Called from mkproj with cwd set to the project directory.
    # Arguments: $1 = project name, $2 = project dir (optional)
    local name="$1"
    local dest="${2:-$PWD}"

    # Normalize path
    dest="$(cd "$dest" && pwd)"

    # Rename any .ino files to match the project name
    # Use nullglob to avoid literal patterns when no files exist
    local old_null
    old_null="$(shopt -p nullglob 2>/dev/null || true)"
    shopt -s nullglob

    local ino
    for ino in "$dest"/*.ino; do
        [[ -f "$ino" ]] || continue
        local base="$(basename "$ino")"
        local newname="${name}.ino"
        if [[ "$base" != "$newname" ]]; then
            mv -- "$ino" "$dest/$newname" 2>/dev/null || warn "Could not rename $base to $newname"
        fi
    done

    # If template included a folder named 'Arduino' (case-insensitive), try to rename or flatten it
    for d in "$dest"/*/; do
        [[ -d "$d" ]] || continue
        local bname="$(basename "$d")"
        if [[ "${bname,,}" == "arduino" ]]; then
            # If there isn't an existing entry with the project name, rename the folder
            if [[ ! -e "$dest/$name" ]]; then
                mv -- "$d" "$dest/$name" 2>/dev/null || warn "Could not rename folder $bname to $name"
            else
                # Otherwise move its contents up and remove the folder
                mv -- "$d"* "$dest/" 2>/dev/null || true
                rmdir -- "$d" 2>/dev/null || true
            fi
        fi
    done

    # restore nullglob
    if [[ -n "$old_null" ]]; then
        eval "$old_null"
    else
        shopt -u nullglob
    fi

    success "Arduino template adjusted: .ino file and folders renamed to '$name'"
}

mkproj_update_arduino() {
    # For now, same behavior as create for updating project files
    mkproj_create_arduino "$@"
}
