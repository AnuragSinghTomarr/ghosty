#!/usr/bin/env bash
# backup.sh — sync live Ghostty setup (configs, themes, fonts) into this repo.
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
XDG="$HOME/.config/ghostty"
APPSUP="$HOME/Library/Application Support/com.mitchellh.ghostty"
PAY="$REPO/payload"

log() { printf '%s [ghosty-backup] %s\n' "$(date '+%F %T')" "$*"; }

# ── configs + custom themes ──────────────────────────────────────────────────
log "configs + themes"
mkdir -p "$PAY/xdg-config" "$PAY/app-support" "$PAY/fonts"
rsync -a --delete --exclude '*.bak' --exclude '.DS_Store' "$XDG/" "$PAY/xdg-config/"
rsync -a "$APPSUP/config" "$PAY/app-support/config"

# ── fonts: auto-discover from font-family values in BOTH configs ─────────────
log "fonts"
rm -f "$PAY/fonts/"*
while IFS= read -r fam; do
  # trim whitespace (BSD sed has no \s) + strip quotes
  fam="$(printf '%s' "$fam" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/^"//;s/"$//')"
  [ -z "$fam" ] && continue
  compact="${fam// /}"                       # "Hack Nerd Font" → HackNerdFont
  found=0
  for f in "$HOME/Library/Fonts/$compact"* "$HOME/Library/Fonts/$fam"*; do
    [ -f "$f" ] && { cp "$f" "$PAY/fonts/"; found=1; }
  done
  [ "$found" = 1 ] || log "NOTE: no user-font files for '$fam' (built-in or brew-managed?)"
done < <(cat "$XDG/config" "$APPSUP/config" 2>/dev/null \
         | grep -E '^[[:space:]]*(window-title-)?font-family[[:space:]]*=' \
         | sed 's/^[^=]*=//' | sort -u)
log "fonts captured: $(ls "$PAY/fonts" | wc -l | tr -d ' ') files"

# ── sanity: the active theme must exist (custom dir or built-in) ─────────────
theme="$(grep -hE '^[[:space:]]*theme[[:space:]]*=' "$APPSUP/config" "$XDG/config" 2>/dev/null | tail -1 | sed 's/^[^=]*=[[:space:]]*//;s/[[:space:]]*$//')"
if [ -n "$theme" ] && [[ "$theme" != *:* ]] && [ ! -f "$PAY/xdg-config/themes/$theme" ]; then
  log "NOTE: active theme '$theme' is not in themes/ — assuming built-in"
fi

# ── commit + push ────────────────────────────────────────────────────────────
cd "$REPO"
git add -A
if git diff --cached --quiet; then
  log "no changes"
else
  git commit -q -m "backup: $(date '+%F %H:%M')"
  git push -q origin main && log "pushed" || log "WARN: push failed (offline? creds?)"
fi
log "done"
