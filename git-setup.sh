#!/bin/bash

# MiniMax Menu Monitor - Git Setup Script
# Run this to initialize git and prepare for GitHub

echo "🚀 Initializing git repository..."

# Initialize git
git init

# Add all files (except .env, Secrets/, etc.)
git add .

# Create initial commit
echo "📝 Creating initial commit..."
git commit -m "Initial commit: MiniMax Menu Monitor v1.0

✨ Features:
- Native macOS menu bar app with liquid glass UI
- Real-time MiniMax API usage tracking
- Dynamic icon showing usage percentage
- Demo mode for UI preview
- Secure Keychain storage
- First-launch setup wizard
- Auto-refresh with live countdown timer

🛠 Built with:
- SwiftUI + AppKit
- XcodeGen project generation
- Native macOS visual effects

📦 Ready for GitHub publication!"

echo ""
echo "✅ Git repository initialized!"
echo ""
echo "Next steps to push to GitHub:"
echo ""
echo "1️⃣  Create a new repository on GitHub.com"
echo "   → Go to https://github.com/new"
echo "   → Repository name: minimax-menu-monitor"
echo "   → Make it Public"
echo "   → Don't initialize with README (we already have one)"
echo ""
echo "2️⃣  Push to GitHub:"
echo "   git remote add origin https://github.com/YOURUSERNAME/minimax-menu-monitor.git"
echo "   git branch -M main"
echo "   git push -u origin main"
echo ""
echo "3️⃣  Celebrate! 🎉"
echo ""
echo "📖 Don't forget to:"
echo "   • Add repo topics: macos, swiftui, menu-bar-app, minimax"
echo "   • Enable Issues and Discussions"
echo "   • Star your own repo! ⭐"
