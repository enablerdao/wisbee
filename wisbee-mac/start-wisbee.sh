#!/bin/bash

# Wisbee Mac App 確実起動スクリプト
# 使用ポート: 8899 (固定)

echo "🐝 Wisbee Mac App を起動中..."

# 設定
WISBEE_PORT=8899
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# 既存プロセスの完全停止
echo "📋 既存プロセスをクリーンアップ中..."
pkill -f "electron.*wisbee" 2>/dev/null || true
pkill -f "ollama-webui-server" 2>/dev/null || true
lsof -ti:${WISBEE_PORT} | xargs kill -9 2>/dev/null || true

# 少し待機
sleep 2

# ポートが空いているか確認
if lsof -i:${WISBEE_PORT} >/dev/null 2>&1; then
    echo "❌ エラー: ポート ${WISBEE_PORT} がまだ使用中です"
    echo "   以下のコマンドで強制終了してから再実行してください:"
    echo "   sudo lsof -ti:${WISBEE_PORT} | xargs kill -9"
    exit 1
fi

# Ollama が動作しているか確認
echo "🔍 Ollama サーバーを確認中..."
if ! curl -s http://localhost:11434/api/version >/dev/null 2>&1; then
    echo "⚠️  Ollama が起動していません。Ollama を起動します..."
    if command -v ollama >/dev/null 2>&1; then
        ollama serve &
        sleep 5
    else
        echo "❌ Ollama がインストールされていません"
        echo "   以下からインストールしてください: https://ollama.ai"
        exit 1
    fi
fi

# ディレクトリ移動
cd "$SCRIPT_DIR"

# Node.js 依存関係確認
if [ ! -d "node_modules" ]; then
    echo "📦 Node.js 依存関係をインストール中..."
    npm install
fi

echo "🚀 Wisbee を起動中 (ポート: ${WISBEE_PORT})..."
echo "🌐 ブラウザで http://localhost:${WISBEE_PORT} にアクセスできます"
echo "📱 Electron デスクトップアプリも同時に起動します"
echo ""
echo "終了するには Ctrl+C を押してください"
echo "----------------------------------------"

# Electron アプリ起動
npm start

echo ""
echo "🛑 Wisbee を停止しました"