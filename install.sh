#!/usr/bin/env bash

set -e

SRC_ARG="$1"
TMP_CLONE_DIR=""
DEFAULT_REPO="https://github.com/SadDevastator/mkproj.git"

if [[ -n "$SRC_ARG" ]]; then
    if [[ -f "$SRC_ARG" ]]; then
        SRC="$SRC_ARG"
    else
        if [[ "$SRC_ARG" =~ github.com ]] || [[ "$SRC_ARG" =~ ^[^/]+/[^/]+$ ]]; then
            TMP_CLONE_DIR=$(mktemp -d)
            if [[ "$SRC_ARG" =~ github.com ]]; then
                REPO_URL="$SRC_ARG"
            else
                REPO_URL="https://github.com/$SRC_ARG.git"
            fi
            echo "Cloning $REPO_URL into $TMP_CLONE_DIR..."
            git clone --depth 1 "$REPO_URL" "$TMP_CLONE_DIR" || { echo "git clone failed" >&2; rm -rf "$TMP_CLONE_DIR"; exit 1; }
            SRC="$TMP_CLONE_DIR/mkproj"
        else
            echo "mkproj not found at $SRC_ARG and argument is not a file or GitHub repo (owner/repo or full URL)." >&2
            exit 1
        fi
    fi
else
    SRC="$(pwd)/mkproj"
    if [[ ! -f "$SRC" ]]; then
        echo "mkproj not found at $SRC. Attempting to clone default repo: $DEFAULT_REPO"
        if ! command -v git >/dev/null 2>&1; then
            echo "git is required to clone $DEFAULT_REPO. Please install git or run this installer from the repo root." >&2
            exit 1
        fi
        TMP_CLONE_DIR=$(mktemp -d)
        git clone --depth 1 "$DEFAULT_REPO" "$TMP_CLONE_DIR" || { echo "git clone failed" >&2; rm -rf "$TMP_CLONE_DIR"; exit 1; }
        SRC="$TMP_CLONE_DIR/mkproj"
        echo "Using mkproj from cloned repo: $DEFAULT_REPO"
    fi
fi

DEST="$HOME/.local/bin"
mkdir -p "$DEST"
INSTALL_PATH="$DEST/mkproj"
cp "$SRC" "$INSTALL_PATH"
chmod +x "$INSTALL_PATH"

ln -sf "$INSTALL_PATH" "$DEST/mkproject"
echo "Created symlink: $DEST/mkproject -> $INSTALL_PATH"

SNIPPET='export PATH="$HOME/.local/bin:$PATH"'
for rc in "$HOME/.profile" "$HOME/.bashrc" "$HOME/.zshrc"; do
    if [[ -f "$rc" ]]; then
        if ! grep -qxF "$SNIPPET" "$rc"; then
            printf "\n%s\n" "$SNIPPET" >> "$rc"
            echo "Updated $rc"
        fi
    else
        printf "%s\n" "$SNIPPET" >> "$rc"
        echo "Created $rc"
    fi
done

if command -v fish >/dev/null 2>&1; then
    fish_conf="$HOME/.config/fish/config.fish"
    fish_snip='set -gx PATH $HOME/.local/bin $PATH'
    mkdir -p "$(dirname "$fish_conf")"
    if ! grep -qxF "$fish_snip" "$fish_conf" 2>/dev/null; then
        printf "\n%s\n" "$fish_snip" >> "$fish_conf"
        echo "Updated fish config"
    fi
fi

echo "Installed mkproj to $INSTALL_PATH"
echo "Attempting to reload your shell profile (best-effort)..."

reloaded=false
if [[ -n "$SHELL" ]]; then
    case $(basename "$SHELL") in
        bash)
            if [[ -f "$HOME/.bashrc" ]]; then
                . "$HOME/.bashrc" && reloaded=true
            fi
            if [[ "$reloaded" != true && -f "$HOME/.profile" ]]; then
                . "$HOME/.profile" && reloaded=true
            fi
            ;;
        zsh)
            if [[ -f "$HOME/.zshrc" ]]; then
                . "$HOME/.zshrc" && reloaded=true
            fi
            ;;
        fish)
            if command -v fish >/dev/null 2>&1; then
                fish -c 'source $HOME/.config/fish/config.fish' >/dev/null 2>&1 && reloaded=true
            fi
            ;;
        *)
            if [[ -f "$HOME/.profile" ]]; then
                . "$HOME/.profile" && reloaded=true
            fi
            ;;
    esac
fi

if [[ "$reloaded" == true ]]; then
    echo "Reloaded shell profile in the current session. If your shell still doesn't see mkproj, restart your shell." 
else
    echo "Could not reload your shell automatically. Restart your shell or run 'source ~/.bashrc' (or your shell's rc file) to pick up the new PATH." 
fi

if [[ -n "$TMP_CLONE_DIR" && -d "$TMP_CLONE_DIR" ]]; then
    rm -rf "$TMP_CLONE_DIR"
fi
