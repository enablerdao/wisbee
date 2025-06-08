#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="quick_output_samples_${TIMESTAMP}.txt"

# 開始時刻
START_TIME=$(date +%s)

# 主要モデル3つ
MODELS=(
  "gemma3:4b"
  "qwen3:latest"
  "phi3:mini"
)

# 2つの代表的な質問
PROMPT1="日本の四季について、それぞれの特徴を簡潔に説明してください。"
PROMPT2="「時は金なり」ということわざの意味を現代的な例で説明してください。"

{
  echo "📝 モデル出力サンプル集"
  echo "実行日時: $(date)"
  echo "========================"
  echo ""
  
  for MODEL in "${MODELS[@]}"; do
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║ MODEL: $MODEL"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    # 質問1: 四季
    echo "【質問1】日本の四季について"
    echo "--------------------------------"
    
    T1_START=$(date +%s)
    RESP1=$(curl -s --max-time 20 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"$PROMPT1\",\"stream\":false,\"options\":{\"temperature\":0.5,\"num_predict\":200}}" \
      2>/dev/null | jq -r '.response // "TIMEOUT"' 2>/dev/null || echo "ERROR")
    T1_END=$(date +%s)
    T1_TIME=$((T1_END - T1_START))
    
    echo "【$MODEL の回答】"
    echo "$RESP1"
    echo ""
    echo "⏱️ 生成時間: ${T1_TIME}秒"
    echo "📏 文字数: $(echo -n "$RESP1" | wc -c)"
    
    # 四季の言及をカウント
    SPRING=$(echo "$RESP1" | grep -o "春" | wc -l)
    SUMMER=$(echo "$RESP1" | grep -o "夏" | wc -l)
    AUTUMN=$(echo "$RESP1" | grep -o "秋" | wc -l)
    WINTER=$(echo "$RESP1" | grep -o "冬" | wc -l)
    echo "🌸 春:$SPRING 🌻 夏:$SUMMER 🍁 秋:$AUTUMN ❄️ 冬:$WINTER"
    echo ""
    
    # 質問2: ことわざ
    echo "【質問2】「時は金なり」の現代的解釈"
    echo "--------------------------------"
    
    T2_START=$(date +%s)
    RESP2=$(curl -s --max-time 20 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"$PROMPT2\",\"stream\":false,\"options\":{\"temperature\":0.5,\"num_predict\":150}}" \
      2>/dev/null | jq -r '.response // "TIMEOUT"' 2>/dev/null || echo "ERROR")
    T2_END=$(date +%s)
    T2_TIME=$((T2_END - T2_START))
    
    echo "【$MODEL の回答】"
    echo "$RESP2"
    echo ""
    echo "⏱️ 生成時間: ${T2_TIME}秒"
    echo "📏 文字数: $(echo -n "$RESP2" | wc -c)"
    
    # 現代的な例があるかチェック
    if [[ "$RESP2" =~ (SNS|スマホ|インターネット|ビジネス|効率|生産性) ]]; then
      echo "✅ 現代的な例あり"
    else
      echo "❌ 現代的な例なし"
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
echo "📄 生成テキストは以下に保存されました:"
echo "→ $OUTPUT_FILE"