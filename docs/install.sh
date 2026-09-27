#!/usr/bin/env bash
set -euo pipefail

app="Budo"
cmd="budo"
base_url="${BUDO_BASE_URL:-https://budo-platform.dev/download}"
install_dir="${BUDO_INSTALL_DIR:-$HOME/.local/bin}"

say() { printf '%s\n' "$*"; }
die() { say "Error: $*" >&2; exit 1; }

arch() {
    case "$(uname -m)" in
        x86_64|amd64)  say "x86_64" ;;
        aarch64|arm64) say "aarch64" ;;
        *) die "unsupported CPU architecture: $(uname -m)" ;;
    esac
}

os() {
    case "$(uname -s)" in
        Linux)  say "linux" ;;
        Darwin) say "macos" ;;
        *) die "unsupported operating system: $(uname -s)" ;;
    esac
}

download() {
    if command -v curl >/dev/null 2>&1; then
        curl -fsSL --proto '=https' --tlsv1.2 -o "$1" "$2"
    elif command -v wget >/dev/null 2>&1; then
        wget -qO "$1" "$2"
    else
        die "curl or wget is required"
    fi
}

if [ "${EUID:-$(id -u)}" -eq 0 ]; then
    die "do not run this installer as root"
fi

platform="$(os)"
binary="$cmd-$platform-$(arch)"
url="$base_url/$binary"
target="$install_dir/$cmd"
tmp="$(mktemp "${TMPDIR:-/tmp}/$cmd.XXXXXX")"
trap 'rm -f "$tmp"' EXIT

say "$app installer"
say "  download: $url"
say "  install:  $target"
say ""

mkdir -p "$install_dir"
download "$tmp" "$url"
install -m 0755 "$tmp" "$target"

say "Installed: $target"

case ":$PATH:" in
    *":$install_dir:"*) ;;
    *)
        say ""
        say "Add this to your shell profile, then open a new terminal:"
        say "  export PATH=\"$install_dir:\$PATH\""
        ;;
esac