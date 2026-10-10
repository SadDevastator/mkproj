#!/usr/bin/env bash
declare -g -A DEPS_C
DEPS_C[make]="make"
DEPS_C[cmake]="cmake"
DEPS_C[gcc]="gcc"

# Point the CMake project name at the new project.
_mkproj_c_set_name() {
    local name="$1" dest="$2"
    [[ -f "$dest/CMakeLists.txt" ]] || return 0
    sed -i "/^set(PROJECT_NAME/,/)/c\\
set(PROJECT_NAME\n    ${name}\n)" "$dest/CMakeLists.txt"
}

mkproj_create_c() {
    local name="$1" dest="$2"

    # mkproj already copied templates/C into $dest
    if [[ -f "$dest/CMakeLists.txt" ]]; then
        _mkproj_c_set_name "$name" "$dest"
        info "Created C project from template: $dest"
        return 0
    fi

    mkdir -p "$dest"
    cat > "$dest/main.c" <<'CMAIN'
#include <stdio.h>

int main(void) {
    printf("Hello, world!\n");
    return 0;
}
CMAIN

    cat > "$dest/CMakeLists.txt" <<CMAKE
cmake_minimum_required(VERSION 3.10)
project(${name})
add_executable(${name} main.c)
CMAKE

    info "Created minimal C project: $dest"
}

mkproj_update_c() {
    # Template files were re-copied over the project; restore its name.
    _mkproj_c_set_name "$1" "$2"
}
