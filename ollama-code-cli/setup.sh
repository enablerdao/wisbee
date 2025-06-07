#!/bin/bash

echo "🚀 Ollama Code CLI セットアップ"
echo "================================"

# Create ocode command
echo "#!/bin/bash" > ocode
echo "python3 $(pwd)/ocode.py \"\$@\"" >> ocode
chmod +x ocode

# Create symlink
if [ -w /usr/local/bin ]; then
    ln -sf $(pwd)/ocode /usr/local/bin/ocode
    echo "✅ /usr/local/bin/ocode にインストールしました"
else
    echo "⚠️  /usr/local/bin への書き込み権限がありません"
    echo "以下のコマンドで手動インストールしてください:"
    echo "  sudo ln -sf $(pwd)/ocode /usr/local/bin/ocode"
fi

# Check Ollama
if ! command -v ollama &> /dev/null; then
    echo "❌ Ollamaがインストールされていません"
    echo "📦 https://ollama.com からインストールしてください"
else
    echo "✅ Ollamaが検出されました"
fi

echo ""
echo "🎯 使い方:"
echo "  ocode                    # 対話モード"
echo "  ocode \"エラーを修正\"      # 単発コマンド"
echo "  ocode -m gemma2:2b      # モデル指定"
echo ""