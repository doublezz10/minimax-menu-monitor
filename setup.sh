#!/bin/bash

# MiniMax Menu Monitor Setup Script
# This script sets up and builds the MiniMax Menu Monitor app

set -e

echo "🔧 MiniMax Menu Monitor Setup"
echo "=============================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Check if .env file exists
if [ ! -f .env ]; then
    print_warning ".env file not found. Creating from template..."
    if [ -f .env.example ]; then
        cp .env.example .env
        print_status "Created .env file from .env.example"
        print_warning "Please edit .env and add your MiniMax API key!"
    else
        print_error ".env.example not found. Please create .env manually."
        exit 1
    fi
else
    print_status ".env file found"
fi

# Check for API key
if grep -q "your_api_key_here" .env 2>/dev/null; then
    print_warning "API key not set in .env file"
    print_warning "Please edit .env and add your MiniMax API key before running"
fi

# Check if XcodeGen is installed
if ! command -v xcodegen &> /dev/null; then
    print_warning "XcodeGen not found. Installing via Homebrew..."
    if command -v brew &> /dev/null; then
        brew install xcodegen
        print_status "XcodeGen installed successfully"
    else
        print_error "Homebrew not found. Please install XcodeGen manually:"
        echo "  brew install xcodegen"
        exit 1
    fi
else
    print_status "XcodeGen found at $(which xcodegen)"
fi

# Generate Xcode project
echo ""
echo "📦 Generating Xcode project..."
xcodegen generate

if [ $? -eq 0 ]; then
    print_status "Xcode project generated successfully"
else
    print_error "Failed to generate Xcode project"
    exit 1
fi

# Build the project
echo ""
echo "🔨 Building project..."
xcodebuild -project MinimaxMenuMonitor.xcodeproj \
    -scheme MinimaxMenuMonitor \
    -configuration Debug \
    -destination 'platform=macOS' \
    build

if [ $? -eq 0 ]; then
    print_status "Build successful!"
    echo ""
    echo "🎉 Setup complete!"
    echo ""
    echo "Next steps:"
    echo "1. Edit .env and add your MiniMax API key"
    echo "2. Open MinimaxMenuMonitor.xcodeproj in Xcode"
    echo "3. Run the app (Cmd+R)"
    echo ""
    echo "To run from command line:"
    echo "  open build/Debug/MinimaxMenuMonitor.app"
else
    print_error "Build failed"
    exit 1
fi
