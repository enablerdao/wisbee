#!/bin/bash

# Simple Wisbee launcher using xcrun simctl

echo "🚀 Starting Wisbee Simple iOS App..."

# Kill any existing simulator
killall "Simulator" 2>/dev/null || true

# Open simulator
open -a Simulator

# Wait for simulator to boot
sleep 3

# Get booted device ID
DEVICE_ID=$(xcrun simctl list devices | grep "Booted" | grep -E -o "[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}" | head -1)

if [ -z "$DEVICE_ID" ]; then
    echo "No booted simulator found. Booting iPhone 15..."
    DEVICE_ID=$(xcrun simctl list devices | grep "iPhone 15" | grep -v "Pro" | head -1 | grep -E -o "[0-9A-F]{8}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{4}-[0-9A-F]{12}")
    xcrun simctl boot $DEVICE_ID
    sleep 5
fi

echo "Device ID: $DEVICE_ID"

# Open Safari with our web UI
echo "Opening Wisbee Web UI in simulator..."
xcrun simctl openurl $DEVICE_ID "http://localhost:8899"

echo "✅ Wisbee is running in the simulator!"
echo "Make sure the Ollama server is running on your Mac (port 8899)"