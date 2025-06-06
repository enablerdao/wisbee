#!/bin/bash

echo "🚀 Ollama Chat UI を起動しています..."

# Check if Ollama service is running
if ! pgrep -x "ollama" > /dev/null; then
    echo "🔄 Ollamaサービスを起動中..."
    ollama serve &
    sleep 3
fi

# Kill any existing Python server on port 8080
if lsof -Pi :8080 -sTCP:LISTEN -t >/dev/null ; then
    echo "🔄 既存のサーバーを停止中..."
    lsof -ti:8080 | xargs kill -9 2>/dev/null
    sleep 1
fi

# Start the Python server
echo "🌐 Webサーバーを起動中..."
cd "$(dirname "$0")"
python3 -m http.server 8080 &
SERVER_PID=$!

# Wait for server to start
sleep 2

# Open browser
echo "🌏 ブラウザを開いています..."
open http://localhost:8080

echo ""
echo "✅ アプリが起動しました！"
echo "📍 URL: http://localhost:8080"
echo ""
echo "🛑 終了するには Ctrl+C を押してください"

# Wait for user to stop
trap "kill $SERVER_PID; exit" INT
wait $SERVER_PID