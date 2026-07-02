#!/usr/bin/env bash
# Refresh the vendored syntax-matrix.json from the canonical copy in
# muxlang/mux-syntax-highlighting. Downloads to a temp file and moves it into
# place only on success, so a failed fetch cannot truncate the vendored copy.
set -euo pipefail

url="https://raw.githubusercontent.com/muxlang/mux-syntax-highlighting/main/shared/syntax-matrix.json"
repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmp="$(mktemp)"
trap 'rm -f "$tmp"' EXIT

curl --proto '=https' -fsSL "$url" -o "$tmp"
mv "$tmp" "$repo_root/syntax-matrix.json"
echo "Updated syntax-matrix.json from canonical."
