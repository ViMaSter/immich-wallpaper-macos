#!/bin/zsh
set -euo pipefail

export PATH="/opt/homebrew/bin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin:${PATH:-}"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOCK_DIR="${TMPDIR:-/tmp}/auto-wallpaper.lock"
REASON="${1:-scheduled}"

# Config
TOKEN=$(cat "$SCRIPT_DIR/token.txt")
URL="https://wallpapers.by.vincent.mahn.ke/?height=9&width=16&token=$TOKEN&darken=60&border=0.1&topOffset=0.25"
OUT_DIR="$HOME/Pictures"
OUT_FILE="$OUT_DIR/auto-wallpaper-$(date '+%Y%m%d').png"
LOG_FILE="$HOME/Library/Logs/auto-wallpaper.log"

mkdir -p "$OUT_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

log() { print -r -- "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"; }

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  log "Skipping wallpaper refresh for $REASON because another run is still active"
  exit 0
fi

cleanup() {
  rm -rf "$LOCK_DIR"
}

trap cleanup EXIT

log "Starting wallpaper fetch ($REASON)"
TMP_FILE=$(mktemp -t wallpaper.XXXXXX.png)

# Download
if command -v curl >/dev/null 2>&1; then
  curl -fsSL "$URL" -o "$TMP_FILE"
else
  log "curl not found"; exit 1
fi

# Verify PNG header (simple check)
if file "$TMP_FILE" | grep -qi 'PNG image'; then
  mv -f "$TMP_FILE" "$OUT_FILE"
  log "Downloaded wallpaper to $OUT_FILE"
else
  log "Downloaded file is not PNG"; rm -f "$TMP_FILE"; exit 1
fi

# Set wallpaper on all desktops
desktoppr "$OUT_FILE"

log "Wallpaper applied ($REASON)"