# MiniMax Menu Monitor

A beautiful native MacOS menu bar app that tracks your MiniMax API usage with a stunning liquid glass interface.

## Features

- 🍏 **Native MacOS Menu Bar App** - Runs quietly in your menu bar
- ✨ **Liquid Glass Interface** - Stunning frosted glass design with smooth animations
- 📊 **Real-time Usage Tracking** - Monitors your MiniMax coding plan usage
- 🔒 **Secure API Key Storage** - Uses macOS Keychain for safe credential storage
- ⚙️ **Customizable Settings** - Configure refresh intervals and preferences
- 🚀 **First-Launch Setup** - Easy API key entry via setup window

## Installation

### Prerequisites

- macOS 12.0 (Monterey) or later
- Xcode 15.0 or later
- Homebrew (recommended for XcodeGen)

### Setup

1. **Clone the repository**
   ```bash
   git clone https://github.com/doublezz10/minimax-menu-monitor.git
   cd minimax-menu-monitor
   ```

2. **Run the setup script**
   ```bash
   chmod +x setup.sh
   ./setup.sh
   ```

   The setup script will:
   - Install XcodeGen if not present
   - Generate the Xcode project
   - Build the app

3. **Run the app**
   ```bash
   open build/Debug/MinimaxMenuMonitor.app
   ```

   Or open `MinimaxMenuMonitor.xcodeproj` in Xcode and press Cmd+R.

4. **First Launch Setup**
   - On first launch, a setup window will appear
   - Enter your MiniMax API key
   - Click "Continue" to start tracking!

### Getting Your MiniMax API Key

1. Visit [MiniMax Platform](https://platform.minimaxi.com)
2. Sign in to your account
3. Navigate to API settings
4. Generate a new API key
5. Enter it in the first-launch setup window

### Demo Mode

You can preview the app UI without providing a real API key:

1. Launch the app
2. Click the menu bar icon and select "Settings" (gear icon)
3. Toggle "Demo Mode" on
4. The app will display simulated usage data so you can preview the liquid glass interface

Demo mode is great for:
- Testing the UI before adding your API key
- Taking screenshots for documentation
- Showing the app to others

## Settings

After launching the app, click the menu bar icon and select "Settings" to configure:
- Change API key (opens setup window)
- Refresh interval
- Demo mode toggle

## Architecture

```
minimax-menu-monitor/
├── project.yml              # XcodeGen configuration
├── setup.sh                 # Build and setup script
├── Sources/
│   ├── App/
│   │   ├── MinimaxMenuMonitorApp.swift
│   │   └── AppDelegate.swift
│   ├── Models/
│   │   ├── UsageResponse.swift
│   │   └── Settings.swift
│   ├── Services/
│   │   ├── MiniMaxAPIService.swift
│   │   ├── KeychainService.swift
│   │   └── UsageMonitor.swift
│   ├── Views/
│   │   ├── ContentView.swift
│   │   ├── UsageView.swift
│   │   ├── SettingsView.swift
│   │   └── Components/
│   │       ├── GlassCard.swift
│   │       ├── LiquidProgressView.swift
│   │       └── GlowingLabel.swift
│   └── Utilities/
│       ├── VisualEffectView.swift
│       └── Extensions/
└── Resources/
    ├── Assets.xcassets/
    ├── Info.plist
    └── MinimaxMenuMonitor.entitlements
```

### Key Components

- **MiniMaxAPIService**: Handles API communication with MiniMax
- **UsageMonitor**: Manages usage data fetching and caching
- **KeychainService**: Secure storage for API credentials
- **GlassCard**: Reusable liquid glass UI component
- **LiquidProgressView**: Animated progress indicator

## Development

### Building

```bash
# Generate Xcode project
xcodegen generate

# Build
xcodebuild -project MinimaxMenuMonitor.xcodeproj \
    -scheme MinimaxMenuMonitor \
    -configuration Debug \
    -destination 'platform=macOS' \
    build
```

### Project Structure

The app follows SwiftUI best practices with:
- Clear separation of concerns
- Reactive data flow using `@StateObject` and `@ObservedObject`
- Dependency injection for testability
- Protocol-oriented design

## Security

- **API Key Storage**: All API keys are stored in macOS Keychain
- **First-Launch Setup**: API keys entered via secure setup window
- **No Hardcoded Secrets**: All credentials loaded at runtime
- **Private by Design**: No external servers, all data stays local

## Contributing

Contributions are welcome! Please read our contributing guidelines before submitting PRs.

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - see LICENSE file for details.

## Acknowledgments

- [MiniMax](https://www.minimaxi.com) for their excellent API
- Apple for SwiftUI and visual effect APIs
- The open-source community for inspiration
