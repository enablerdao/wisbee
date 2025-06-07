#!/bin/bash

echo "==================================="
echo "Wisbee Cross-Platform Build Script"
echo "==================================="

# Check dependencies
echo "Checking dependencies..."

if ! command -v node &> /dev/null; then
    echo "Error: Node.js is required. Please install it first."
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "Error: npm is required. Please install it first."
    exit 1
fi

# Install dependencies if needed
if [ ! -d "node_modules" ]; then
    echo "Installing dependencies..."
    npm install
fi

# Create icons for all platforms
if [ ! -f "assets/icon.ico" ]; then
    echo "Creating platform icons..."
    ./create-icons.sh
fi

# Clean previous builds
echo "Cleaning previous builds..."
rm -rf dist/

# Build for all platforms
echo "Building for all platforms..."
echo "This may take several minutes..."

# Build based on current platform
case "$OSTYPE" in
  darwin*)
    echo "Building on macOS..."
    npm run dist-all
    ;;
  linux*)
    echo "Building on Linux..."
    # On Linux, can't build for Mac
    npm run dist-win
    npm run dist-linux
    ;;
  msys*|cygwin*|win32*)
    echo "Building on Windows..."
    # On Windows, can't build for Mac
    npm run dist-win
    npm run dist-linux
    ;;
  *)
    echo "Unknown OS: $OSTYPE"
    exit 1
    ;;
esac

echo ""
echo "Build complete! Check the dist/ directory for installers:"
echo ""
ls -la dist/

echo ""
echo "Platform-specific installers:"
echo "- Windows: .exe (NSIS installer) and .exe (portable)"
echo "- macOS: .dmg and .app"
echo "- Linux: .AppImage, .deb, and .rpm"