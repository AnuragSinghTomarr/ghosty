#!/usr/bin/env bash
# bootstrap.sh — restore the full Ghostty setup on a fresh macOS machine.
# Safe to re-run. Existing configs are saved aside as *.pre-bootstrap.bak once.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PAY="$REPO/payload"
XDG="$HOME/.config/ghostty"
APPSUP="$HOME/Library/Application Support/com.mitchellh.ghostty"

log() { printf '\033[1;36m[ghosty]\033[0m %s\n' "$*"; }
[ -d "$PAY" ] || { echo "payload/ missing — run backup.sh on the old machine first."; exit 1; }

# ── 1. Homebrew + Ghostty ────────────────────────────────────────────────────
if ! command -v brew >/dev/null; then
  log "installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(/opt/homebrew/bin/brew shellenv 2>/dev/null || /usr/local/bin/brew shellenv)"
if [ ! -d "/Applications/Ghostty.app" ]; then
  log "installing Ghostty"
  brew install --cask ghostty
fi

# ── 2. configs + themes (back up anything already there, once) ───────────────
for f in "$XDG/config" "$APPSUP/config"; do
  [ -f "$f" ] && [ ! -f "$f.pre-bootstrap.bak" ] && cp "$f" "$f.pre-bootstrap.bak"
done
mkdir -p "$XDG" "$APPSUP"
log "restoring configs + themes"
rsync -a "$PAY/xdg-config/" "$XDG/"
rsync -a "$PAY/app-support/config" "$APPSUP/config"

# ── 3. fonts ─────────────────────────────────────────────────────────────────
log "installing $(ls "$PAY/fonts" | wc -l | tr -d ' ') font files"
mkdir -p "$HOME/Library/Fonts"
cp "$PAY/fonts/"* "$HOME/Library/Fonts/"

log "DONE — open Ghostty. Theme: $(grep -E '^[[:space:]]*theme[[:space:]]*=' "$APPSUP/config" | tail -1 | sed 's/^[^=]*=[[:space:]]*//')"
log "If Ghostty was already running: reload config with cmd+shift+, (or restart it)"
