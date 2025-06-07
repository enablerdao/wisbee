#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="final_output_collection_${TIMESTAMP}.txt"

# 開始時刻
START_TIME=$(date +%s)

# 2モデルで短時間テスト
MODELS=(
  "gemma3:4b"
  "llama3.2:1b"
)

{
  echo "📚 最終出力コレクション"
  echo "======================"
  echo "実行日時: $(date)"
  echo ""
  
  for MODEL in "${MODELS[@]}"; do
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║ MODEL: $MODEL"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    # テスト1: ストーリー生成
    echo "📖 テスト1: 短いストーリーを作成"
    echo "プロンプト: 「雨の日の猫」というタイトルで50文字程度の短い話を書いて"
    echo "---"
    
    T1_START=$(date +%s)
    STORY=$(curl -s --max-time 15 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"「雨の日の猫」というタイトルで50文字程度の短い話を書いてください。\",\"stream\":false,\"options\":{\"temperature\":0.7,\"num_predict\":100}}" \
      2>/dev/null | jq -r '.response // "ERROR"' 2>/dev/null || echo "TIMEOUT")
    T1_END=$(date +%s)
    
    echo "【生成されたストーリー】"
    echo "$STORY"
    echo ""
    echo "⏱️ ${T1_END - T1_START}秒 | 📏 $(echo -n "$STORY" | wc -c)文字"
    echo ""
    
    # テスト2: 技術的説明
    echo "🔧 テスト2: 技術的な説明"
    echo "プロンプト: HTTPとHTTPSの違いを一言で"
    echo "---"
    
    T2_START=$(date +%s)
    TECH=$(curl -s --max-time 15 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"HTTPとHTTPSの違いを一言で説明してください。\",\"stream\":false,\"options\":{\"temperature\":0.1,\"num_predict\":50}}" \
      2>/dev/null | jq -r '.response // "ERROR"' 2>/dev/null || echo "TIMEOUT")
    T2_END=$(date +%s)
    
    echo "【生成された説明】"
    echo "$TECH"
    echo ""
    echo "⏱️ ${T2_END - T2_START}秒 | 📏 $(echo -n "$TECH" | wc -c)文字"
    echo ""
    
    # テスト3: リスト生成
    echo "📝 テスト3: リスト生成"
    echo "プロンプト: プログラミング言語を3つ挙げて"
    echo "---"
    
    T3_START=$(date +%s)
    LIST=$(curl -s --max-time 15 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"プログラミング言語を3つ挙げてください。\",\"stream\":false,\"options\":{\"temperature\":0.3,\"num_predict\":50}}" \
      2>/dev/null | jq -r '.response // "ERROR"' 2>/dev/null || echo "TIMEOUT")
    T3_END=$(date +%s)
    
    echo "【生成されたリスト】"
    echo "$LIST"
    echo ""
    echo "⏱️ ${T3_END - T3_START}秒 | 📏 $(echo -n "$LIST" | wc -c)文字"
    
    # 言語の数をカウント
    LANG_COUNT=$(echo "$LIST" | grep -E "Python|Java|JavaScript|C\+\+|Ruby|Go|Swift|Kotlin|PHP|Rust" | wc -l)
    echo "🔢 認識された言語数: $LANG_COUNT"
    echo ""
    
    # テスト4: 感情分析
    echo "😊 テスト4: 感情分析"
    echo "プロンプト: 「今日は最高の一日だった！」この文章の感情は？"
    echo "---"
    
    T4_START=$(date +%s)
    EMOTION=$(curl -s --max-time 15 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"「今日は最高の一日だった！」この文章の感情を分析してください。\",\"stream\":false,\"options\":{\"temperature\":0.2,\"num_predict\":50}}" \
      2>/dev/null | jq -r '.response // "ERROR"' 2>/dev/null || echo "TIMEOUT")
    T4_END=$(date +%s)
    
    echo "【生成された分析】"
    echo "$EMOTION"
    echo ""
    echo "⏱️ ${T4_END - T4_START}秒 | 📏 $(echo -n "$EMOTION" | wc -c)文字"
    
    if [[ "$EMOTION" =~ (ポジティブ|positive|喜び|嬉しい|幸せ|楽しい) ]]; then
      echo "✅ 正しく感情を認識"
    else
      echo "❌ 感情認識に課題"
    fi
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
echo "📄 全生成テキスト保存先: $OUTPUT_FILE"