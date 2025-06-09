#!/bin/bash

# Create iconset directory
mkdir -p Wisbee.iconset

# Copy and rename files for iconset
cp macos-icons/icon_16x16.png Wisbee.iconset/icon_16x16.png
cp macos-icons/icon_16x16@2x.png Wisbee.iconset/icon_16x16@2x.png
cp macos-icons/icon_32x32.png Wisbee.iconset/icon_32x32.png
cp macos-icons/icon_32x32@2x.png Wisbee.iconset/icon_32x32@2x.png
cp macos-icons/icon_128x128.png Wisbee.iconset/icon_128x128.png
cp macos-icons/icon_128x128@2x.png Wisbee.iconset/icon_128x128@2x.png
cp macos-icons/icon_256x256.png Wisbee.iconset/icon_256x256.png
cp macos-icons/icon_256x256@2x.png Wisbee.iconset/icon_256x256@2x.png
cp macos-icons/icon_512x512.png Wisbee.iconset/icon_512x512.png
cp macos-icons/icon_512x512@2x.png Wisbee.iconset/icon_512x512@2x.png

# Create icns file
iconutil -c icns Wisbee.iconset -o Wisbee.icns

# Clean up
rm -rf Wisbee.iconset

echo "✅ Created Wisbee.icns successfully!"