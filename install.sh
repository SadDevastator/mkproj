#!/usr/bin/env bash

set -e

SRC_ARG="$1"
TMP_CLONE_DIR=""
DEFAULT_REPO="https://github.com/SadDevastator/mkproj.git"

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
BOLD="\033[1m"
RESET="\033[0m"

info() { printf "%b\n" "${BLUE}${1}${RESET}"; }
success() { printf "%b\n" "${GREEN}${1}${RESET}"; }
warn() { printf "%b\n" "${YELLOW}${1}${RESET}"; }
err() { printf "%b\n" "${RED}${1}${RESET}"; }

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
            info "Cloning $REPO_URL into $TMP_CLONE_DIR..."
            git clone --depth 1 "$REPO_URL" "$TMP_CLONE_DIR" || { err "git clone failed" >&2; rm -rf "$TMP_CLONE_DIR"; exit 1; }
            SRC="$TMP_CLONE_DIR/mkproj"
        else
            echo "mkproj not found at $SRC_ARG and argument is not a file or GitHub repo (owner/repo or full URL)." >&2
            exit 1
        fi
    fi
else
    SRC="$(pwd)/mkproj"
    if [[ ! -f "$SRC" ]]; then
    warn "mkproj not found at $SRC. Attempting to clone default repo: $DEFAULT_REPO"
        if ! command -v git >/dev/null 2>&1; then
            echo "git is required to clone $DEFAULT_REPO. Please install git or run this installer from the repo root." >&2
            exit 1
        fi
        TMP_CLONE_DIR=$(mktemp -d)
        git clone --depth 1 "$DEFAULT_REPO" "$TMP_CLONE_DIR" || { err "git clone failed" >&2; rm -rf "$TMP_CLONE_DIR"; exit 1; }
        SRC="$TMP_CLONE_DIR/mkproj"
        info "Using mkproj from cloned repo: $DEFAULT_REPO"
    fi
fi

DEST="$HOME/.local/bin"
mkdir -p "$DEST"
INSTALL_PATH="$DEST/mkproj"
cp "$SRC" "$INSTALL_PATH"
chmod +x "$INSTALL_PATH"

ln -sf "$INSTALL_PATH" "$DEST/mkproject"
success "Created symlink: $DEST/mkproject -> $INSTALL_PATH"

src_dir="$(cd "$(dirname "$SRC")" && pwd)"
templates_src="$src_dir/templates"
config_src="$src_dir/config"
user_templates="$HOME/.config/mkproj/templates"
user_config="$HOME/.config/mkproj/config"
mkdir -p "$user_templates" "$user_config"

if [[ -d "$templates_src" ]]; then
    info "Installing bundled templates from $templates_src"
    for d in "$templates_src"/*; do
        [[ -d "$d" ]] || continue
        base="$(basename "$d")"
        if [[ -e "$user_templates/$base" ]]; then
            info "User template '$base' already exists, skipping"
        else
            cp -a "$d" "$user_templates/" 2>/dev/null || cp -r "$d" "$user_templates/" 2>/dev/null || true
            success "Installed bundled template: $base"
        fi
    done
fi

if [[ -d "$config_src" ]]; then
    info "Installing default config files from $config_src"
    for f in "$config_src"/*; do
        [[ -f "$f" ]] || continue
        base="$(basename "$f")"
        if [[ -f "$user_config/$base" ]]; then
            if cmp -s "$f" "$user_config/$base"; then
                info "Config '$base' is up to date"
            else
                # Bundled modules track the hook API of this mkproj version; keep the old copy.
                cp "$user_config/$base" "$user_config/$base.bak"
                cp "$f" "$user_config/"
                warn "Updated config '$base' (previous version saved as $base.bak)"
            fi
        else
            cp "$f" "$user_config/"
            success "Installed default config: $base"
        fi
    done
fi

data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
if [[ -f "$src_dir/man/mkproj.1" ]]; then
    # man-db finds ~/.local/share/man automatically when ~/.local/bin is on PATH
    mkdir -p "$data_home/man/man1"
    cp "$src_dir/man/mkproj.1" "$data_home/man/man1/mkproj.1"
    success "Installed man page to $data_home/man/man1/mkproj.1"
fi
if [[ -f "$src_dir/tldr/mkproj.md" ]] && tldr --version 2>/dev/null | grep -qi tealdeer; then
    mkdir -p "$data_home/tealdeer/pages"
    cp "$src_dir/tldr/mkproj.md" "$data_home/tealdeer/pages/mkproj.page.md"
    success "Installed tldr page to $data_home/tealdeer/pages/mkproj.page.md"
fi

# Shell setup: PATH and completions. Either append to rc files (auto) or print
# the snippets so users with custom shell configs can place them (manual).
# MKPROJ_SHELL_SETUP=auto|manual skips the prompt.
shell_setup="${MKPROJ_SHELL_SETUP:-}"
if [[ "$shell_setup" != "auto" && "$shell_setup" != "manual" ]]; then
    shell_setup="auto"
    if { : </dev/tty; } 2>/dev/null; then
        printf "\nmkproj can add PATH and shell completion setup to the end of your shell config files.\n" >/dev/tty
        read -r -p "Append automatically, or print the snippets for you to add yourself? [A/m]: " ans </dev/tty || ans=""
        [[ "$ans" =~ ^[Mm] ]] && shell_setup="manual"
    fi
fi
manual_steps=()

# Append a line to an rc file once.
add_line() {
    local rc="$1" line="$2"
    mkdir -p "$(dirname "$rc")"
    if ! grep -qxF "$line" "$rc" 2>/dev/null; then
        printf "\n%s\n" "$line" >> "$rc"
        info "Updated $rc"
    fi
}

zshrc="${ZDOTDIR:-$HOME}/.zshrc"
login_shell="$(basename "${SHELL:-bash}")"

SNIPPET='export PATH="$HOME/.local/bin:$PATH"'
case ":$PATH:" in
    *":$DEST:"*) ;;  # already on PATH (e.g. set in a custom config)
    *)
        if [[ "$shell_setup" == "auto" ]]; then
            for rc in "$HOME/.profile" "$HOME/.bashrc" "$zshrc"; do
                # Only touch rc files that exist, plus the login shell's own rc
                if [[ -f "$rc" ]] \
                    || [[ "$login_shell" == "bash" && "$rc" == "$HOME/.bashrc" ]] \
                    || [[ "$login_shell" == "zsh" && "$rc" == "$zshrc" ]]; then
                    add_line "$rc" "$SNIPPET"
                fi
            done
        else
            manual_steps+=("Add ~/.local/bin to PATH (bash/zsh rc):" "    $SNIPPET")
        fi
        if command -v fish >/dev/null 2>&1; then
            fish_snip='set -gx PATH $HOME/.local/bin $PATH'
            if [[ "$shell_setup" == "auto" ]]; then
                add_line "$HOME/.config/fish/config.fish" "$fish_snip"
            else
                manual_steps+=("Add ~/.local/bin to PATH (fish config):" "    $fish_snip")
            fi
        fi
        ;;
esac

comp_dir="$HOME/.config/mkproj/completions"
mkdir -p "$comp_dir"
if command -v zsh >/dev/null 2>&1; then
    "$INSTALL_PATH" completions zsh > "$comp_dir/_mkproj"
    zsh_line='[[ -r "$HOME/.config/mkproj/completions/_mkproj" ]] && source "$HOME/.config/mkproj/completions/_mkproj"  # mkproj completions'
    if [[ "$shell_setup" == "auto" ]]; then
        add_line "$zshrc" "$zsh_line"
        success "Installed zsh completions"
    else
        manual_steps+=(
            "Enable zsh completions, either after compinit in your zshrc:"
            "    $zsh_line"
            "  or by adding the directory to fpath before compinit runs:"
            "    fpath=(\"\$HOME/.config/mkproj/completions\" \$fpath)"
        )
    fi
fi
if command -v fish >/dev/null 2>&1; then
    fish_comp="$HOME/.config/fish/completions/mkproj.fish"
    if [[ "$shell_setup" == "auto" ]]; then
        mkdir -p "$(dirname "$fish_comp")"
        "$INSTALL_PATH" completions fish > "$fish_comp"
        success "Installed fish completions to $fish_comp"
    else
        manual_steps+=("Enable fish completions:" "    mkproj completions fish > ~/.config/fish/completions/mkproj.fish")
    fi
fi

if [[ ${#manual_steps[@]} -gt 0 ]]; then
    echo
    info "Manual shell setup (nothing was written to your shell config):"
    printf "  %s\n" "${manual_steps[@]}"
    echo
fi

success "Installed mkproj to $INSTALL_PATH"
info "Attempting to reload your shell profile (best-effort)..."

reloaded=false
if [[ -n "$SHELL" ]]; then
    shellname="$(basename "$SHELL")"
    if [[ "$shellname" == "fish" ]]; then
        fish_conf="$HOME/.config/fish/config.fish"
        if [[ -f "$fish_conf" ]]; then
            fish -c "source $fish_conf" >/dev/null 2>&1 && reloaded=true
        fi
    else
        candidates=("$HOME/.bashrc" "$HOME/.profile" "$HOME/.zshrc" "$HOME/.config/fish/config.fish")
        for rc in "${candidates[@]}"; do
            [[ -f "$rc" ]] || continue
            if "$SHELL" -c "source \"$rc\" >/dev/null 2>&1"; then
                reloaded=true
                break
            fi
            if "$SHELL" -c ". \"$rc\" >/dev/null 2>&1"; then
                reloaded=true
                break
            fi
        done
    fi
fi

if [[ "$reloaded" == true ]]; then
    success "Reloaded shell profile in the current session. If your shell still doesn't see mkproj, restart your shell." 
else
    warn "Could not reload your shell automatically. Restart your shell or run 'source ~/.bashrc' (or your shell's rc file) to pick up the new PATH." 
fi

if [[ -n "$TMP_CLONE_DIR" && -d "$TMP_CLONE_DIR" ]]; then
    rm -rf "$TMP_CLONE_DIR"
fi
