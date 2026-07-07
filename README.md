# ghosty — Ghostty terminal backup & new-Mac bootstrap

Private repo. Complete Ghostty setup: both config files, custom themes, and the
exact font files — restorable on a fresh macOS machine with one line.

## New Mac (the one-liner)

```bash
git clone https://github.com/AnuragSinghTomarr/ghosty.git ~/workspace/self/ghosty && bash ~/workspace/self/ghosty/bootstrap.sh
```

Installs Homebrew (if missing) → Ghostty.app → restores configs + themes →
installs fonts. Open Ghostty and it looks identical.

## After changing your Ghostty setup

```bash
bash backup.sh     # re-syncs configs/themes/fonts → commits → pushes
```

## What's captured (and why both configs matter)

| Piece | Live path | In repo |
|---|---|---|
| XDG config (fonts fallback, padding, scrollback, shell-integration…) | `~/.config/ghostty/config` | `payload/xdg-config/config` |
| App Support config — **loads second and wins** (CommitMono primary, font-features, `theme = PaperInkLinenV2`, minimum-contrast) | `~/Library/Application Support/com.mitchellh.ghostty/config` | `payload/app-support/config` |
| Custom themes (PaperInkLinen, PaperInkLinenV2, PaperInkInverse) | `~/.config/ghostty/themes/` | `payload/xdg-config/themes/` |
| Fonts: CommitMono (manual install) + Hack / Hack Nerd Font | `~/Library/Fonts/` | `payload/fonts/` |

Built-in themes (`ghostty +list-themes`) ship inside Ghostty.app — nothing to
back up. Ghostty has no plugin system; themes + shaders + config are the whole
customization surface (no shaders in use — if you add `custom-shader` files
later, add their dir to backup.sh).

`backup.sh` auto-discovers fonts: it reads every `font-family` value from both
configs and copies matching files from `~/Library/Fonts/` — so switching fonts
is picked up on the next backup without editing scripts.
