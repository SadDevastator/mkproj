#!/usr/bin/env bash
declare -g -A DEPS_C
DEPS_C[make]="make"
DEPS_C[cmake]="cmake"
DEPS_C[gcc]="gcc"

mkproj_create_c() {
    local name="$1" target_dir="$2" dest template_src
    dest="$target_dir/$name"

    if [[ -n "$TEMPLATES_DIR" && -d "$TEMPLATES_DIR/C" ]]; then
        template_src="$TEMPLATES_DIR/C"
    elif [[ -n "$script_dir" && -d "$script_dir/templates/C" ]]; then
        template_src="$script_dir/templates/C"
    else
        template_src=""
    fi

    if [[ -n "$template_src" ]]; then
        mkdir -p "$dest"
        cp -r "$template_src/." "$dest/"

        if [[ -f "$dest/CMakeLists.txt" ]]; then
            sed -i "/^set(PROJECT_NAME/,/)/c\\
set(PROJECT_NAME\n    ${name}\n)" "$dest/CMakeLists.txt" || true
        fi

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
cmake_minimum_required(VERSION 3.0)
project(${name})
add_executable(${name} main.c)
CMAKE

    info "Created minimal C project: $dest"
}

mkproj_update_c() {
    local name="$1" target_dir="$2" dest
    dest="$target_dir/$name"
    if [[ ! -d "$dest" ]]; then
        err "Project directory '$dest' does not exist; cannot update."
        return 1
    fi
    info "No update actions defined for C projects yet."
}
