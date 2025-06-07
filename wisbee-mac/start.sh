#!/bin/bash
cd /Users/yuki/bench-llm/wisbee-mac

# Kill any existing processes
pkill -f "ollama-webui-server" || true
pkill -f "Electron" || true

# Start Python server in background
python3 ollama-webui-server.py 8899 &
SERVER_PID=$!

# Wait a bit for server to start
sleep 2

# Start Electron app
./node_modules/.bin/electron .

# Kill server when app exits
kill $SERVER_PID 2>/dev/null || true