#!/bin/bash

# Wisbee iOS Release Build Script
# This script builds the iOS app for App Store release

set -e

echo "🚀 Wisbee iOS Release Build Script"
echo "=================================="

# Configuration
PROJECT_NAME="Wisbee"
SCHEME_NAME="Wisbee"
CONFIGURATION="Release"
ARCHIVE_PATH="./build/${PROJECT_NAME}.xcarchive"
EXPORT_PATH="./build/exports"
EXPORT_OPTIONS_PLIST="./ExportOptions.plist"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Functions
print_step() {
    echo -e "\n${GREEN}▶ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠ $1${NC}"
}

print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

# Check prerequisites
print_step "Checking prerequisites..."

if ! command -v xcodebuild &> /dev/null; then
    print_error "xcodebuild not found. Please install Xcode."
    exit 1
fi

if ! command -v xcrun &> /dev/null; then
    print_error "xcrun not found. Please install Xcode Command Line Tools."
    exit 1
fi

# Check for Xcode project
if [ ! -f "${PROJECT_NAME}.xcodeproj/project.pbxproj" ]; then
    print_error "Xcode project not found. Please run this script from the project root."
    exit 1
fi

print_success "Prerequisites checked"

# Clean previous builds
print_step "Cleaning previous builds..."
rm -rf ./build
mkdir -p ./build/exports
print_success "Clean complete"

# Resolve package dependencies
print_step "Resolving package dependencies..."
xcodebuild -resolvePackageDependencies -project "${PROJECT_NAME}.xcodeproj" -scheme "${SCHEME_NAME}"
print_success "Dependencies resolved"

# Build archive
print_step "Building archive for App Store..."
xcodebuild archive \
    -project "${PROJECT_NAME}.xcodeproj" \
    -scheme "${SCHEME_NAME}" \
    -configuration "${CONFIGURATION}" \
    -archivePath "${ARCHIVE_PATH}" \
    -destination "generic/platform=iOS" \
    -allowProvisioningUpdates \
    DEVELOPMENT_TEAM="${DEVELOPMENT_TEAM}" \
    CODE_SIGN_STYLE="Automatic" \
    | xcpretty

if [ ! -d "${ARCHIVE_PATH}" ]; then
    print_error "Archive failed. Please check the build logs."
    exit 1
fi

print_success "Archive created successfully"

# Create ExportOptions.plist if it doesn't exist
if [ ! -f "${EXPORT_OPTIONS_PLIST}" ]; then
    print_step "Creating ExportOptions.plist..."
    cat > "${EXPORT_OPTIONS_PLIST}" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>\${DEVELOPMENT_TEAM}</string>
    <key>uploadSymbols</key>
    <true/>
    <key>compileBitcode</key>
    <false/>
    <key>stripSwiftSymbols</key>
    <true/>
    <key>thinning</key>
    <string>&lt;none&gt;</string>
</dict>
</plist>
EOF
    print_success "ExportOptions.plist created"
fi

# Export IPA
print_step "Exporting IPA for App Store..."
xcodebuild -exportArchive \
    -archivePath "${ARCHIVE_PATH}" \
    -exportPath "${EXPORT_PATH}" \
    -exportOptionsPlist "${EXPORT_OPTIONS_PLIST}" \
    -allowProvisioningUpdates \
    | xcpretty

if [ ! -f "${EXPORT_PATH}/${PROJECT_NAME}.ipa" ]; then
    print_error "IPA export failed. Please check the export logs."
    exit 1
fi

print_success "IPA exported successfully"

# Validate the app
print_step "Validating app for App Store..."
xcrun altool --validate-app \
    -f "${EXPORT_PATH}/${PROJECT_NAME}.ipa" \
    -t ios \
    --apiKey "${APP_STORE_API_KEY}" \
    --apiIssuer "${APP_STORE_ISSUER_ID}" \
    || print_warning "Validation failed. You can validate manually in Xcode Organizer."

# Display results
echo -e "\n${GREEN}════════════════════════════════════════════${NC}"
echo -e "${GREEN}✅ Build Complete!${NC}"
echo -e "${GREEN}════════════════════════════════════════════${NC}"
echo ""
echo "📦 Archive Location: ${ARCHIVE_PATH}"
echo "📱 IPA Location: ${EXPORT_PATH}/${PROJECT_NAME}.ipa"
echo ""
echo "Next steps:"
echo "1. Open Xcode Organizer (Window > Organizer)"
echo "2. Select the archive and click 'Distribute App'"
echo "3. Follow the App Store Connect upload wizard"
echo ""
echo "Or use this command to upload:"
echo "xcrun altool --upload-app -f \"${EXPORT_PATH}/${PROJECT_NAME}.ipa\" -t ios --apiKey \${APP_STORE_API_KEY} --apiIssuer \${APP_STORE_ISSUER_ID}"
echo ""

# Create build info file
cat > "./build/build_info.txt" <<EOF
Build Information
=================
Date: $(date)
Project: ${PROJECT_NAME}
Configuration: ${CONFIGURATION}
Archive: ${ARCHIVE_PATH}
IPA: ${EXPORT_PATH}/${PROJECT_NAME}.ipa

Environment Variables Required:
- DEVELOPMENT_TEAM: Your Apple Developer Team ID
- APP_STORE_API_KEY: App Store Connect API Key
- APP_STORE_ISSUER_ID: App Store Connect Issuer ID

To find your Team ID:
1. Open Xcode
2. Select your project
3. Go to Signing & Capabilities
4. Look for "Team" dropdown

To create App Store Connect API Key:
1. Go to https://appstoreconnect.apple.com/
2. Users and Access > Keys
3. Create a new key with App Manager role
EOF

print_success "Build info saved to ./build/build_info.txt"