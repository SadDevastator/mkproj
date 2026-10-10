#!/usr/bin/env bash

# Go projects: go mod init + main.go, then go generate.
# The variant is the module path, e.g. go:github.com/you/app (defaults to the project name).

declare -g -A DEPS_GO
DEPS_GO[go]="go"

mkproj_create_go() {
    local name="$1" dest="$2" module="${3:-$1}"
    require_cmd go || return 1

    mkdir -p "$dest"
    (cd "$dest" && go mod init "$module") || return 1

    if [[ ! -f "$dest/main.go" ]]; then
        cat > "$dest/main.go" <<'GOMAIN'
package main

import "fmt"

//go:generate go vet ./...

func main() {
	fmt.Println("Hello, world!")
}
GOMAIN
    fi

    (cd "$dest" && go generate ./...)
}

mkproj_update_go() {
    local dest="$2"
    require_cmd go || return 1
    (cd "$dest" && go generate ./... && go mod tidy)
}
