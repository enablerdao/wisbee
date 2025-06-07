#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="final_outputs_fixed_${TIMESTAMP}.txt"

# 開始時刻
START_TIME=$(date +%s)

# 3モデルで実施
MODELS=(
  "gemma3:4b"
  "phi3:mini"
  "llama3.2:1b"
)

{
  echo "📚 モデル生成テキスト完全版"
  echo "=========================="
  echo "実行日時: $(date)"
  echo ""
  
  for MODEL in "${MODELS[@]}"; do
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║ MODEL: $MODEL"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    # テスト1: ストーリー生成
    echo "📖 【テスト1】短いストーリー生成"
    echo "質問: 「雨の日の猫」というタイトルで短い話を書いて"
    echo "---"
    
    STORY=$(curl -s --max-time 15 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"「雨の日の猫」というタイトルで短い話を書いてください。\",\"stream\":false,\"options\":{\"temperature\":0.7,\"num_predict\":100}}" \
      2>/dev/null | jq -r '.response // "ERROR"' 2>/dev/null || echo "TIMEOUT")
    
    echo "生成されたテキスト:"
    echo "「$STORY」"
    echo "文字数: $(echo -n "$STORY" | wc -c)"
    echo ""
    
    # テスト2: 技術説明
    echo "🔧 【テスト2】技術的説明"
    echo "質問: HTTPとHTTPSの違いを説明して"
    echo "---"
    
    TECH=$(curl -s --max-time 15 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"HTTPとHTTPSの違いを簡潔に説明してください。\",\"stream\":false,\"options\":{\"temperature\":0.1,\"num_predict\":100}}" \
      2>/dev/null | jq -r '.response // "ERROR"' 2>/dev/null || echo "TIMEOUT")
    
    echo "生成されたテキスト:"
    echo "「$TECH」"
    echo ""
    
    # テスト3: 感情分析
    echo "😊 【テスト3】感情分析"
    echo "質問: 「今日は最高の一日だった！」の感情は？"
    echo "---"
    
    EMOTION=$(curl -s --max-time 15 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"「今日は最高の一日だった！」この文章の感情を一言で。\",\"stream\":false,\"options\":{\"temperature\":0.2,\"num_predict\":30}}" \
      2>/dev/null | jq -r '.response // "ERROR"' 2>/dev/null || echo "TIMEOUT")
    
    echo "生成されたテキスト:"
    echo "「$EMOTION」"
    echo ""
    
    # テスト4: コード生成
    echo "💻 【テスト4】コード生成"
    echo "質問: Pythonで1から10までの合計を計算"
    echo "---"
    
    CODE=$(curl -s --max-time 15 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"Pythonで1から10までの合計を計算するコードを書いて。\",\"stream\":false,\"options\":{\"temperature\":0.1,\"num_predict\":100}}" \
      2>/dev/null | jq -r '.response // "ERROR"' 2>/dev/null || echo "TIMEOUT")
    
    echo "生成されたテキスト:"
    echo "「$CODE」"
    echo ""
    
    # テスト5: 翻訳
    echo "🌍 【テスト5】翻訳"
    echo "質問: 「Good morning」を日本語に翻訳"
    echo "---"
    
    TRANS=$(curl -s --max-time 15 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"Good morningを日本語に翻訳してください。\",\"stream\":false,\"options\":{\"temperature\":0.1,\"num_predict\":20}}" \
      2>/dev/null | jq -r '.response // "ERROR"' 2>/dev/null || echo "TIMEOUT")
    
    echo "生成されたテキスト:"
    echo "「$TRANS」"
    echo ""
    
    echo "═══════════════════════════════════════════════════════════════"
    echo ""
  done
  
  END_TIME=$(date +%s)
  TOTAL_TIME=$((END_TIME - START_TIME))
  
  echo "⏱️ 総実行時間: ${TOTAL_TIME}秒"
  echo "📅 終了時刻: $(date)"
} | tee "$OUTPUT_FILE"

echo ""
echo "📄 全ての生成テキストが保存されました: $OUTPUT_FILE"