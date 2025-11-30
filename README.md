# SleepShield 🛡️

**Prevent battery drain on your MacBook by automatically disabling WiFi during sleep.**

## The Problem

Many MacBook users experience significant battery drain overnight, even when the laptop is in sleep mode. This is often caused by background processes (particularly Chrome and other apps) making network requests that prevent deep sleep and drain your battery.

## The Solution

SleepShield automatically turns off your WiFi when your MacBook goes to sleep and restores it when you wake up. This ensures:
- ✅ True deep sleep without network interruptions
- ✅ Significant battery savings overnight
- ✅ Your WiFi automatically reconnects when you open your laptop
- ✅ Simple, lightweight, and runs in the background

## Features

- 🌙 Automatically disables WiFi when closing your laptop lid
- ☀️ Automatically re-enables WiFi when opening your laptop
- 🎯 Only affects WiFi that was on before sleep (won't turn on WiFi if it was already off)
- 🔄 Manual testing with simulate sleep/wake buttons
- 💻 Native macOS app with minimal resource usage

## Requirements

- macOS 12.0 or later (tested on macOS Sequoia 15.6.1)
- MacBook with WiFi

## Installation

### Option 1: Download Pre-built App (Easiest)

**⚠️ Important: This app is unsigned. macOS will show security warnings. This is normal for open-source apps.**

1. Download the latest `SleepShield-v1.0-macOS.zip` from the [Releases](https://github.com/graemedoherty/SleepShield/releases) page

2. Unzip the downloaded file (double-click it)

3. Move `SleepShield.app` to your Applications folder

4. **Remove the quarantine flag** (this allows the app to run):
   - Open **Terminal** (search for it in Spotlight)
   - Copy and paste this command, then press Enter:
     ```bash
     xattr -cr /Applications/SleepShield.app
     ```

5. **Open the app:**
   - Go to your Applications folder
   - **Right-click** (or Control+click) on `SleepShield.app`
   - Select **"Open"**
   - If you see a security warning, click **"Open"** again to confirm

**Alternative method if the above doesn't work:**
- Try opening the app normally (it will be blocked)
- Go to **System Settings → Privacy & Security**
- Scroll down and click **"Open Anyway"** next to the SleepShield message
- Click **"Open"** to confirm

**Why is this necessary?**
This app is not code-signed with an Apple Developer certificate ($99/year). The quarantine flag and security warnings are macOS protecting you from unsigned software. Since this is open-source and you can review the code, it's safe to bypass these warnings.

### Option 2: Build from Source

**Requirements:**
- Xcode 15.0 or later
- macOS development environment

**Steps:**

1. Clone the repository:
```bash
git clone https://github.com/graemedoherty/SleepShield.git
cd SleepShield
```

2. Open the project in Xcode:
```bash
open SleepShield.xcodeproj
```

3. Build and run:
   - Select your Mac as the build target
   - Press `⌘ + R` to build and run
   - Or Product → Archive to create a distributable app

**Important:** The app requires App Sandbox to be **disabled** to control WiFi. This is already configured in the project.

## Usage

1. **Launch the app** - SleepShield will appear with a simple control window
2. **Keep it running** - The app runs in the background and monitors sleep/wake events
3. **Test it** - Use the "Simulate Sleep" and "Simulate Wake" buttons to test functionality
4. **Close your laptop** - WiFi will automatically turn off when sleeping
5. **Open your laptop** - WiFi will automatically turn back on

### Optional: Run on Startup

To have SleepShield start automatically when you log in:

1. Open **System Settings**
2. Go to **General → Login Items**
3. Click the **+** button under "Open at Login"
4. Select **SleepShield** from your Applications folder
5. Click **Add**

## How It Works

SleepShield uses macOS's native `NSWorkspace` notifications to detect when your Mac goes to sleep or wakes up. When sleep is detected, it:

1. Checks if WiFi is currently enabled
2. Saves this state
3. Disables WiFi using the `networksetup` command-line tool
4. On wake, restores WiFi to its previous state

The app continuously tracks WiFi state (every 30 seconds) to ensure it knows the correct state even if you manually toggle WiFi while awake.

## Troubleshooting

### "Apple could not verify SleepShield is free of malware"
This is expected for unsigned apps. Follow these steps:
1. Open Terminal
2. Run: `xattr -cr /Applications/SleepShield.app`
3. Right-click the app and select "Open"

### "App cannot be opened" or other security warnings
- Make sure you've removed the quarantine flag (see installation step 4)
- Try: System Settings → Privacy & Security → click "Open Anyway"
- Or right-click → Open instead of double-clicking

### WiFi doesn't turn off during sleep
- Make sure the app is running (check Activity Monitor)
- Ensure "Enable SleepShield" toggle is ON in the app
- Check Console.app for debug logs

### WiFi doesn't turn back on after wake
- The app tracks your WiFi state - if WiFi was off before sleep, it won't turn it back on
- Try the "Simulate" buttons to test functionality
- Restart the app to reset state tracking

### "App cannot be opened" security warning
- Right-click the app and select "Open" instead of double-clicking
- Or go to System Settings → Privacy & Security and allow the app to run

### Permission Issues
- The app needs to run commands to control WiFi
- If it's not working, check System Settings → Privacy & Security for any blocks

## Privacy & Security

- ✅ **No data collection** - SleepShield runs entirely locally on your Mac
- ✅ **No network requests** - The app never connects to the internet
- ✅ **Open source** - Full source code available for inspection
- ⚠️ **Requires App Sandbox disabled** - Necessary to control system WiFi settings

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development Setup

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Known Issues

- Wake notification fires twice on some macOS versions (harmless, working as expected)
- First-time launch requires right-click → Open due to unsigned app (unless code signed)

## Roadmap

- [ ] Bluetooth control option (v1.1)
- [ ] Menu bar-only mode (hide window)
- [ ] Customizable sleep delay
- [ ] Battery threshold option (only disable WiFi below X% battery)
- [ ] Notification support
- [ ] App icon design

## License

MIT License - see [LICENSE](LICENSE) file for details

## Acknowledgments

Created to solve the persistent battery drain issue affecting MacBook users. Inspired by the need for a simple, reliable solution to prevent background network activity during sleep.

## Support

If you find this app helpful, please star the repository ⭐ and share it with others experiencing the same issue!

For issues or questions, please open an issue on GitHub.

---

**Disclaimer:** This app modifies system WiFi settings. Use at your own risk. Always ensure you have a way to manually enable WiFi if needed.
