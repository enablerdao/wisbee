#!/bin/bash

echo "🚀 Ollama Chat UI セットアップスクリプト"
echo "===================================="

# Check if Ollama is installed
if ! command -v ollama &> /dev/null; then
    echo "❌ Ollamaがインストールされていません"
    echo "📦 Ollamaをインストールしています..."
    curl -fsSL https://ollama.com/install.sh | sh
else
    echo "✅ Ollamaがインストール済みです"
fi

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "❌ Python3がインストールされていません"
    echo "Homebrewを使用してインストールしてください: brew install python3"
    exit 1
else
    echo "✅ Python3がインストール済みです"
fi

# Check and start Ollama service
if ! pgrep -x "ollama" > /dev/null; then
    echo "🔄 Ollamaサービスを起動しています..."
    ollama serve &
    sleep 5
else
    echo "✅ Ollamaサービスが実行中です"
fi

# Download recommended models
echo ""
echo "📥 推奨モデルをダウンロードしています..."
echo "これには時間がかかる場合があります"

models=(
    "qwen3:1.7b"
    "smollm2:135m"
    "smollm2:360m"
    "gemma2:2b"
)

for model in "${models[@]}"; do
    echo ""
    echo "📦 $model をダウンロード中..."
    ollama pull "$model"
done

echo ""
echo "✅ セットアップが完了しました！"
echo ""
echo "🎯 アプリを起動するには以下を実行してください:"
echo "   ./start.sh"
echo ""