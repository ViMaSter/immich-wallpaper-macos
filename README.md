# Auto Wallpaper via launchd (macOS)

This setup downloads a PNG from the specified URL every 24 hours and sets it as the desktop background for all spaces.

Requires an instance of a [wallpaper server](https://github.com/mahn-ke/wallpapers-by-vincent/).

## Files
- `wallpaper.sh`: Downloads the image and applies it as wallpaper.
- `wallpaper-display-change.sh`: Polls the live macOS display topology and re-runs the wallpaper script when displays are added or removed.
- `com.vimaster.wallpaper.rotate.plist`: User LaunchAgent to run the script every 24h and at login.
- `com.vimaster.wallpaper.onwake.plist`: User LaunchAgent to run the script whenever the device wakes from sleep.
- `com.vimaster.wallpaper.ondisplaychange.plist`: User LaunchAgent to react to monitor and docking changes.

## Install
1. Install desktoppr using `brew install --cask desktoppr`
2. Clone this repository
3. Replace all occurences of `/Users/vimaster/rotate/` in `com.vimaster.wallpaper.rotate.plist` with the path to your cloned repo.
4. Replace all occurences of `/Users/vimaster/rotate/` in `com.vimaster.wallpaper.onwake.plist` with the path to your cloned repo.
5. Replace all occurences of `/Users/vimaster/rotate/` in `com.vimaster.wallpaper.ondisplaychange.plist` with the path to your cloned repo.
6. Replace all occurences of `wallpapers.by.vincent.mahn.ke` in `wallpaper.sh` with your wallpaper server domain.
7. Create a file named `token.txt` in the same directory as `wallpaper.sh` containing your APP_TOKEN.
8. Open Terminal and run:
```bash
# Make the script executable
chmod +x ~/rotate/wallpaper.sh
chmod +x ~/rotate/wallpaper-display-change.sh

# Copy the LaunchAgent into place
cp ~/rotate/com.vimaster.wallpaper.rotate.plist ~/Library/LaunchAgents/
cp ~/rotate/com.vimaster.wallpaper.onwake.plist ~/Library/LaunchAgents/
cp ~/rotate/com.vimaster.wallpaper.ondisplaychange.plist ~/Library/LaunchAgents/

# Load the agents
launchctl unload ~/Library/LaunchAgents/com.vimaster.wallpaper.rotate.plist 2>/dev/null || true
launchctl load ~/Library/LaunchAgents/com.vimaster.wallpaper.rotate.plist
launchctl unload ~/Library/LaunchAgents/com.vimaster.wallpaper.onwake.plist 2>/dev/null || true
launchctl load ~/Library/LaunchAgents/com.vimaster.wallpaper.onwake.plist
launchctl unload ~/Library/LaunchAgents/com.vimaster.wallpaper.ondisplaychange.plist 2>/dev/null || true
launchctl load ~/Library/LaunchAgents/com.vimaster.wallpaper.ondisplaychange.plist

# Verify status
launchctl list | grep com.vimaster.wallpaper.rotate || echo "Agent not listed yet"
launchctl list | grep com.vimaster.wallpaper.ondisplaychange || echo "Display-change agent not listed yet"

# Run once manually to test
~/rotate/wallpaper.sh
```

## Notes
- Logs are written to `~/Library/Logs/auto-wallpaper.log`.
- The display-change LaunchAgent polls the current output of `system_profiler SPDisplaysDataType` every 15 seconds and only runs the wallpaper refresh when that fingerprint changes.
- To remove: `launchctl unload ~/Library/LaunchAgents/com.vimaster.wallpaper.rotate.plist && launchctl unload ~/Library/LaunchAgents/com.vimaster.wallpaper.onwake.plist && launchctl unload ~/Library/LaunchAgents/com.vimaster.wallpaper.ondisplaychange.plist` and delete the files.
