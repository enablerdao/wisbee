#!/bin/bash

# 🐝 Bee installer script

echo "🐝 Installing Bee CLI..."

# Check if running as root
if [ "$EUID" -eq 0 ]; then 
    PREFIX="/usr/local/bin"
else
    PREFIX="$HOME/.local/bin"
    mkdir -p "$PREFIX"
fi

# Copy bee to bin directory
cp bee "$PREFIX/bee"
chmod +x "$PREFIX/bee"

# Add to PATH if needed
if [[ ":$PATH:" != *":$PREFIX:"* ]]; then
    echo ""
    echo "⚠️  $PREFIX is not in your PATH"
    echo "Add this to your ~/.zshrc or ~/.bashrc:"
    echo "export PATH=\"$PREFIX:\$PATH\""
fi

echo "✅ Bee installed successfully!"
echo ""
echo "Usage: bee"
echo "Help:  bee --help"