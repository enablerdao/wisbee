#!/bin/bash

echo "🚀 Setting up Wisbee Mac App..."

# Install dependencies
echo "📦 Installing dependencies..."
npm install

# Create icon if needed
mkdir -p assets
echo "✨ Creating placeholder icon..."
touch assets/icon.png
touch assets/icon.icns

echo "✅ Setup complete!"
echo ""
echo "To run Wisbee:"
echo "  npm start"
echo ""
echo "To build for distribution:"
echo "  npm run dist"