#!/bin/bash

# Package Ollama Chat UI for distribution

PACKAGE_NAME="ollama-chat-ui"
VERSION="1.0.0"
DIST_DIR="dist"
PACKAGE_DIR="$DIST_DIR/$PACKAGE_NAME"

echo "📦 Packaging Ollama Chat UI v$VERSION"
echo "===================================="

# Clean and create directories
rm -rf "$DIST_DIR"
mkdir -p "$PACKAGE_DIR"

# Copy necessary files
echo "📄 Copying files..."
cp index.html "$PACKAGE_DIR/"
cp style.css "$PACKAGE_DIR/"
cp config.json "$PACKAGE_DIR/"
cp setup.sh "$PACKAGE_DIR/"
cp start.sh "$PACKAGE_DIR/"
cp README.md "$PACKAGE_DIR/"
cp requirements.txt "$PACKAGE_DIR/"

# Create zip archive
echo "🗜 Creating archive..."
cd "$DIST_DIR"
zip -r "$PACKAGE_NAME-$VERSION.zip" "$PACKAGE_NAME"

# Create tar.gz archive
tar -czf "$PACKAGE_NAME-$VERSION.tar.gz" "$PACKAGE_NAME"

echo ""
echo "✅ パッケージ作成完了！"
echo "📦 dist/$PACKAGE_NAME-$VERSION.zip"
echo "📦 dist/$PACKAGE_NAME-$VERSION.tar.gz"
echo ""
echo "配布方法："
echo "1. 上記のファイルをダウンロード"
echo "2. 解凍して ./setup.sh を実行"
echo "3. ./start.sh でアプリを起動"