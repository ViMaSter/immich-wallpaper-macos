#!/bin/zsh
set -euo pipefail

# Config
TOKEN=$(cat "$(dirname "$0")/token.txt")
URL="https://wallpapers.by.vincent.mahn.ke/?height=9&width=16&token=$TOKEN&darken=60"
OUT_DIR="$HOME/Pictures"
OUT_FILE="$OUT_DIR/auto-wallpaper-$(date '+%Y%m%d').png"
LOG_FILE="$HOME/Library/Logs/auto-wallpaper.log"

mkdir -p "$OUT_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

log() { echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"; }

log "Starting wallpaper fetch"
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
osascript <<OSA
tell application "Finder"
  set desktop picture to POSIX file "$OUT_FILE"
end tell
OSA

log "Wallpaper applied"