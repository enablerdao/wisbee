#!/bin/bash

# Create Windows ICO file from PNG
# Requires ImageMagick: brew install imagemagick

echo "Creating Windows icon (.ico) from existing PNG..."

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick is required. Please install it with: brew install imagemagick"
    exit 1
fi

# Create ICO with multiple sizes for Windows
convert assets/icon.png -resize 16x16 assets/icon-16.png
convert assets/icon.png -resize 32x32 assets/icon-32.png
convert assets/icon.png -resize 48x48 assets/icon-48.png
convert assets/icon.png -resize 64x64 assets/icon-64.png
convert assets/icon.png -resize 128x128 assets/icon-128.png
convert assets/icon.png -resize 256x256 assets/icon-256.png

# Combine into ICO file
convert assets/icon-16.png assets/icon-32.png assets/icon-48.png assets/icon-64.png assets/icon-128.png assets/icon-256.png assets/icon.ico

# Clean up temporary files
rm assets/icon-16.png assets/icon-32.png assets/icon-48.png assets/icon-64.png assets/icon-128.png assets/icon-256.png

echo "Windows icon created: assets/icon.ico"

# Create Linux icon directories
echo "Creating Linux icon directories..."
mkdir -p assets/linux
for size in 16 32 48 64 128 256 512; do
    convert assets/icon.png -resize ${size}x${size} assets/linux/${size}x${size}.png
done

echo "Linux icons created in assets/linux/"
echo "Icon creation complete!"