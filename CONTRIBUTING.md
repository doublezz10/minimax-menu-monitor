# Contributing to MiniMax Menu Monitor

Thank you for your interest in contributing! This project is evolving toward a premium multi-model tracking platform, and we welcome contributions at all levels.

## How You Can Help

### ⭐ Star the Repo
Simple but effective - stars increase visibility and help attract contributors.

### 🐛 Report Bugs
Found an issue? Open a GitHub issue with:
- Steps to reproduce
- Expected behavior
- Actual behavior
- macOS version
- App version

### 💡 Suggest Features
Have an idea for the premium version (multi-provider tracking, cost analytics, etc.)? Open a feature request with:
- Description of the feature
- Use case (why it's useful)
- Optional: mockups or examples

### 🔧 Submit Pull Requests
Want to contribute code?

**For v1.0 (Free):**
- Bug fixes
- UI/UX improvements
- Documentation

**For v2.0 (Premium):**
- New AI provider integrations
- Analytics features
- Cost tracking

## Development Setup

```bash
# Clone the repo
git clone https://github.com/yourusername/minimax-menu-monitor.git
cd minimax-menu-monitor

# Generate Xcode project
xcodegen generate

# Build and run
open MinimaxMenuMonitor.xcodeproj
```

## Project Structure

```
minimax-menu-monitor/
├── Sources/
│   ├── App/              # App lifecycle, menu bar
│   ├── Models/           # Data models
│   ├── Services/         # API, keychain, monitoring
│   ├── Views/            # UI components
│   └── Utilities/        # Helpers, extensions
├── Resources/            # Assets, Info.plist
├── project.yml           # XcodeGen config
└── ROADMAP.md            # Product roadmap
```

## Coding Standards

- SwiftUI for all UI components
- @MainActor for thread safety
- Protocol-oriented design
- Clear naming conventions
- Comments for complex logic

## Provider Integration

Want to add support for a new AI provider? See ROADMAP.md for the planned provider architecture.

**Key files to modify:**
- `Sources/Services/MiniMaxAPIService.swift` → Template for new providers
- `Sources/Models/UsageResponse.swift` → Data model updates
- `Sources/Views/UsageView.swift` → UI updates

## Getting Help

- Check existing issues first
- Read the README and ROADMAP.md
- Open an issue for questions

## Code of Conduct

Be respectful, inclusive, and constructive. We're all here to build something great!

---

**Together we can build the ultimate AI usage tracking platform.** 🚀
