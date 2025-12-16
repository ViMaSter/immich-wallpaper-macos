# Auto Wallpaper via launchd (macOS)

This setup downloads a PNG from the specified URL every 24 hours and sets it as the desktop background for all spaces.

Requires an instance of a [wallpaper server](https://github.com/mahn-ke/wallpapers-by-vincent/).

## Files
- `wallpaper.sh`: Downloads the image and applies it as wallpaper.
- `com.vimaster.wallpaper.rotate.plist`: User LaunchAgent to run the script every 24h and at login.

## Install
1. Clone this repository
2. Replace all occurences of `/Users/vimaster/rotate/` in `com.vimaster.wallpaper.rotate.plist` with the path to your cloned repo.
3. Replace all occurences of `wallpapers.by.vincent.mahn.ke` in `wallpaper.sh` with your wallpaper server domain.
3. Create a file named `token.txt` in the same directory as `wallpaper.sh` containing your APP_TOKEN.
4. Open Terminal and run:
```bash
# Make the script executable
chmod +x ~/rotate/wallpaper.sh

# Copy the LaunchAgent into place
cp ~/rotate/com.vimaster.wallpaper.rotate.plist ~/Library/LaunchAgents/

# Load the agent
launchctl unload ~/Library/LaunchAgents/com.vimaster.wallpaper.rotate.plist 2>/dev/null || true
launchctl load ~/Library/LaunchAgents/com.vimaster.wallpaper.rotate.plist

# Verify status
launchctl list | grep com.vimaster.wallpaper.rotate || echo "Agent not listed yet"

# Run once manually to test
~/rotate/wallpaper.sh
```

## Notes
- Logs are written to `~/Library/Logs/auto-wallpaper.log`.
- To remove: `launchctl unload ~/Library/LaunchAgents/com.vimaster.wallpaper.rotate.plist` and delete the files.
