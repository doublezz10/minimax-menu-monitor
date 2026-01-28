# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-28

### Added
- Initial public release
- Menu bar icon with circular usage indicator (Apple-native design)
- Real-time MiniMax API usage tracking
- First-launch API key setup flow
- Configurable refresh interval (10-300 seconds)
- Live countdown to quota reset
- Secure Keychain storage for API keys
- Glassmorphism UI design system
- Comprehensive typography, color, and spacing design tokens
- Error handling with user-friendly messages

### Changed
- Redesigned menu bar icon (removed black border, Apple-native style)
- Complete UI consistency overhaul (typography, colors, spacing)
- Enhanced error messages for better user experience
- Optimized timer performance (10-second intervals)

### Fixed
- Memory leak prevention in UsageMonitor

### Technical
- Centralized logging system (AppLogger)
- Unit tests for API service
- Unit tests for Settings model
- Protocol-oriented architecture
- SwiftUI for all UI components

---

## Installation

### Option 1: Homebrew (Coming Soon)
```bash
brew install minimax-menu-monitor
```

### Option 2: Direct Download
1. Download the latest release from [GitHub Releases](https://github.com/doublezz10/minimax-menu-monitor/releases)
2. Extract the `.zip` file
3. Drag `MinimaxMenuMonitor.app` to your Applications folder
4. Launch the app

### Option 3: Build from Source
```bash
git clone/doublezz10/minimax-menu-m https://github.comonitor.git
cd minimax-menu-monitor
chmod +x setup.sh
./setup.sh
open MinimaxMenuMonitor.xcodeproj
```

Press `⌘ + R` to build and run.

---

## Usage

1. **First Launch**: Enter your MiniMax API key when prompted
2. **Menu Bar**: The icon shows your usage percentage (circular indicator)
3. **Click Icon**: Opens the usage popover with detailed stats
4. **Settings**: Click the gear icon to configure refresh interval or update API key

### Menu Bar Icon
- **Cyan ring**: 0-50% usage (healthy)
- **Amber ring**: 50-80% usage (moderate)
- **Red ring**: 80-100% usage (high)

---

## Configuration

### API Key
Your API key is stored securely in the macOS Keychain. To update:
1. Click the menu bar icon
2. Click the gear icon (Settings)
3. Click "Change" to enter a new key

### Refresh Interval
Configure how often the app checks your usage (10-300 seconds):
1. Click the menu bar icon
2. Click the gear icon (Settings)
3. Adjust the slider

---

## Troubleshooting

### App won't start
- Ensure macOS 12.0 or later is installed
- Check that the app is unzipped completely
- Try right-clicking and selecting "Open"

### Usage not showing
- Verify your API key is correct in Settings
- Check your internet connection
- Ensure you have MiniMax API access

### Menu bar icon not visible
- The icon may be hidden in the overflow menu (▼)
- Check System Settings → Control Center → Other Menus

### High CPU usage
- Reduce the refresh interval in Settings
- The default is 60 seconds which is recommended

---

## Support

- **Issues**: [GitHub Issues](https://github.com/doublezz10/minimax-menu-monitor/issues)
- **Discussions**: [GitHub Discussions](https://github.com/doublezz10/minimax-menu-monitor/discussions)
- **Feature Requests**: Open an issue with the "enhancement" label

---

## Privacy

This app:
- ✅ Stores your API key securely in the macOS Keychain
- ✅ Only transmits data to the official MiniMax API
- ✅ Does not collect any personal data
- ✅ Does not use analytics or tracking
- ✅ Works entirely offline (after initial setup)

---

## License

MIT License - see [LICENSE](LICENSE) for details.

---

## Acknowledgments

- [MiniMax](https://minimax.io/) for their API
- [Apple](https://developer.apple.com/) for SwiftUI and macOS
- [SF Symbols](https://developer.apple.com/sf-symbols/) for beautiful icons
