#!/bin/bash
cd /Users/yuki/bench-llm/wisbee-mac

# Kill any existing processes
pkill -f "enhanced-server.py" || true
pkill -f "ollama-webui-server" || true
pkill -f "Electron" || true
lsof -ti:8899 | xargs kill -9 2>/dev/null || true

# Clear Electron cache to ensure new design loads
rm -rf ~/Library/Application\ Support/Wisbee/Cache 2>/dev/null || true
rm -rf ~/Library/Application\ Support/Wisbee/GPUCache 2>/dev/null || true

# Start enhanced Python server in background
python3 enhanced-server.py &
SERVER_PID=$!

# Wait a bit for server to start
sleep 2

# Start Electron app
./node_modules/.bin/electron .

# Kill server when app exits
kill $SERVER_PID 2>/dev/null || true