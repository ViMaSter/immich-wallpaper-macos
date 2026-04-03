#!/bin/zsh
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LOG_FILE="$HOME/Library/Logs/auto-wallpaper.log"
STATE_DIR="$HOME/Library/Caches/auto-wallpaper"
STATE_FILE="$STATE_DIR/display-topology.sha1"
LOCK_DIR="$STATE_DIR/display-watch.lock"

mkdir -p "$STATE_DIR"
mkdir -p "$(dirname "$LOG_FILE")"

log() { print -r -- "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"; }

if ! mkdir "$LOCK_DIR" 2>/dev/null; then
  exit 0
fi

cleanup() {
  rm -rf "$LOCK_DIR"
}

trap cleanup EXIT

if ! command -v system_profiler >/dev/null 2>&1; then
  log "Display watcher cannot run because system_profiler is unavailable"
  exit 1
fi

current_fingerprint="$(system_profiler -json SPDisplaysDataType | shasum | awk '{print $1}')"

previous_fingerprint=""
if [[ -f "$STATE_FILE" ]]; then
  previous_fingerprint="$(<"$STATE_FILE")"
fi

if [[ "$current_fingerprint" == "$previous_fingerprint" ]]; then
  exit 0
fi

print -r -- "$current_fingerprint" > "$STATE_FILE"
if [[ -z "$previous_fingerprint" ]]; then
  exit 0
fi

log "Detected display configuration change"
exec "$SCRIPT_DIR/wallpaper.sh" display-change