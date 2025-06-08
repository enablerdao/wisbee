#!/bin/bash

# Create iOS App Icons from base icon
# Requires ImageMagick: brew install imagemagick

echo "Creating iOS App Icons..."

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "ImageMagick is required. Please install it with: brew install imagemagick"
    exit 1
fi

# Create Assets directory structure
mkdir -p Wisbee/Assets.xcassets/AppIcon.appiconset

# Base icon should be at least 1024x1024
BASE_ICON="../wisbee-mac/assets/icon.png"

if [ ! -f "$BASE_ICON" ]; then
    echo "Error: Base icon not found at $BASE_ICON"
    echo "Creating a placeholder icon..."
    
    # Create a placeholder gradient icon
    convert -size 1024x1024 \
        -define gradient:angle=135 \
        gradient:'#667eea-#764ba2' \
        -draw "fill white font-size 400 gravity center text 0,0 'W'" \
        Wisbee/Assets.xcassets/AppIcon.appiconset/icon-1024.png
    
    BASE_ICON="Wisbee/Assets.xcassets/AppIcon.appiconset/icon-1024.png"
fi

# iOS App Icon sizes
declare -a SIZES=(
    "20:1,2,3"      # 20x20 @1x,2x,3x
    "29:1,2,3"      # 29x29 @1x,2x,3x  
    "40:1,2,3"      # 40x40 @1x,2x,3x
    "60:2,3"        # 60x60 @2x,3x
    "76:1,2"        # 76x76 @1x,2x (iPad)
    "83.5:2"        # 83.5x83.5 @2x (iPad Pro)
    "1024:1"        # 1024x1024 @1x (App Store)
)

# Generate icons
for SIZE_SPEC in "${SIZES[@]}"; do
    IFS=':' read -r SIZE SCALES <<< "$SIZE_SPEC"
    IFS=',' read -ra SCALE_ARRAY <<< "$SCALES"
    
    for SCALE in "${SCALE_ARRAY[@]}"; do
        if [ "$SCALE" == "1" ]; then
            SUFFIX=""
            PIXELS="$SIZE"
        else
            SUFFIX="@${SCALE}x"
            PIXELS=$(echo "$SIZE * $SCALE" | bc)
        fi
        
        OUTPUT_NAME="icon-${SIZE}${SUFFIX}.png"
        OUTPUT_PATH="Wisbee/Assets.xcassets/AppIcon.appiconset/$OUTPUT_NAME"
        
        echo "Creating $OUTPUT_NAME (${PIXELS}x${PIXELS}px)..."
        convert "$BASE_ICON" -resize "${PIXELS}x${PIXELS}" "$OUTPUT_PATH"
    done
done

# Create Contents.json for the App Icon set
cat > Wisbee/Assets.xcassets/AppIcon.appiconset/Contents.json << 'EOF'
{
  "images" : [
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "20x20",
      "filename" : "icon-20@2x.png"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "20x20",
      "filename" : "icon-20@3x.png"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "29x29",
      "filename" : "icon-29@2x.png"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "29x29",
      "filename" : "icon-29@3x.png"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "40x40",
      "filename" : "icon-40@2x.png"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "40x40",
      "filename" : "icon-40@3x.png"
    },
    {
      "idiom" : "iphone",
      "scale" : "2x",
      "size" : "60x60",
      "filename" : "icon-60@2x.png"
    },
    {
      "idiom" : "iphone",
      "scale" : "3x",
      "size" : "60x60",
      "filename" : "icon-60@3x.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "20x20",
      "filename" : "icon-20.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "20x20",
      "filename" : "icon-20@2x.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "29x29",
      "filename" : "icon-29.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "29x29",
      "filename" : "icon-29@2x.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "40x40",
      "filename" : "icon-40.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "40x40",
      "filename" : "icon-40@2x.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "1x",
      "size" : "76x76",
      "filename" : "icon-76.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "76x76",
      "filename" : "icon-76@2x.png"
    },
    {
      "idiom" : "ipad",
      "scale" : "2x",
      "size" : "83.5x83.5",
      "filename" : "icon-83.5@2x.png"
    },
    {
      "idiom" : "ios-marketing",
      "scale" : "1x",
      "size" : "1024x1024",
      "filename" : "icon-1024.png"
    }
  ],
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

# Create Assets.xcassets Contents.json
cat > Wisbee/Assets.xcassets/Contents.json << 'EOF'
{
  "info" : {
    "author" : "xcode",
    "version" : 1
  }
}
EOF

echo "✅ App icons created successfully!"
echo "📁 Location: Wisbee/Assets.xcassets/AppIcon.appiconset/"
echo ""
echo "Next steps:"
echo "1. Open Wisbee.xcodeproj in Xcode"
echo "2. Verify icons in Assets catalog"
echo "3. Build and test the app"