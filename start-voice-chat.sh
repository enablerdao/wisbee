#!/usr/bin/env bash
# Start voice chat services

echo "🎙️ Starting Ollama Voice Chat Services..."

# Check if Python 3 is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python 3 is required but not installed."
    echo "Install with: brew install python3"
    exit 1
fi

# Check if Ollama is running
if ! curl -s http://localhost:11434/api/tags > /dev/null; then
    echo "❌ Ollama is not running. Please start Ollama first."
    echo "Run: ollama serve"
    exit 1
fi

# Install dependencies if needed
echo "📦 Checking dependencies..."
if ! python3 -c "import aiohttp" 2>/dev/null; then
    echo "Installing Python dependencies..."
    pip3 install -r requirements-voice.txt
fi

# Start the voice server
echo "🚀 Starting voice server on port 8890..."
/opt/homebrew/Caskroom/miniconda/base/bin/python enhanced-voice-server.py &
SERVER_PID=$!

# Wait for server to start
sleep 2

# Open the voice chat interface
echo "🌐 Opening voice chat interface..."
if command -v open &> /dev/null; then
    open "http://localhost:8890/enhanced-voice-chat.html"
else
    echo "➡️ Open http://localhost:8890/enhanced-voice-chat.html in your browser"
fi

echo "✅ Voice chat is running!"
echo "Press Ctrl+C to stop the server"

# Wait for Ctrl+C
trap "kill $SERVER_PID; echo '👋 Voice chat stopped.'; exit 0" INT
wait $SERVER_PID