#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="quick_3q_results_${TIMESTAMP}.txt"

# 開始時刻
START_TIME=$(date +%s)

# 最速モデル2つだけテスト
MODELS=(
  "gemma3:4b"
  "jaahas/qwen3-abliterated:0.6b"
)

# 3つの簡単な質問
echo "🚀 クイック3問テスト" | tee "$OUTPUT_FILE"
echo "=================" | tee -a "$OUTPUT_FILE"

for MODEL in "${MODELS[@]}"; do
  echo -e "\n📦 $MODEL" | tee -a "$OUTPUT_FILE"
  
  # Q1: 算数
  echo -n "Q1: 2+2=? → " | tee -a "$OUTPUT_FILE"
  R1=$(curl -s --max-time 5 http://localhost:11434/api/generate \
    -d "{\"model\":\"$MODEL\",\"prompt\":\"2+2=\",\"stream\":false,\"options\":{\"temperature\":0,\"num_predict\":5}}" \
    2>/dev/null | jq -r '.response // "ERROR"' | tr -d '\n' | cut -c1-10)
  
  if [[ "$R1" =~ 4 ]]; then
    echo "✅ $R1" | tee -a "$OUTPUT_FILE"
  else
    echo "❌ $R1" | tee -a "$OUTPUT_FILE"
  fi
  
  # Q2: 日本
  echo -n "Q2: 日本の首都? → " | tee -a "$OUTPUT_FILE"
  R2=$(curl -s --max-time 5 http://localhost:11434/api/generate \
    -d "{\"model\":\"$MODEL\",\"prompt\":\"日本の首都は？\",\"stream\":false,\"options\":{\"temperature\":0,\"num_predict\":10}}" \
    2>/dev/null | jq -r '.response // "ERROR"' | tr -d '\n' | cut -c1-10)
  
  if [[ "$R2" =~ 東京 ]]; then
    echo "✅ $R2" | tee -a "$OUTPUT_FILE"
  else
    echo "❌ $R2" | tee -a "$OUTPUT_FILE"
  fi
  
  # Q3: 英語
  echo -n "Q3: Hello=? → " | tee -a "$OUTPUT_FILE"
  R3=$(curl -s --max-time 5 http://localhost:11434/api/generate \
    -d "{\"model\":\"$MODEL\",\"prompt\":\"Hello を日本語で\",\"stream\":false,\"options\":{\"temperature\":0,\"num_predict\":10}}" \
    2>/dev/null | jq -r '.response // "ERROR"' | tr -d '\n' | cut -c1-20)
  
  if [[ "$R3" =~ (こんにちは|ハロー) ]]; then
    echo "✅ $R3" | tee -a "$OUTPUT_FILE"
  else
    echo "❌ $R3" | tee -a "$OUTPUT_FILE"
  fi
done

END_TIME=$(date +%s)
TOTAL=$((END_TIME - START_TIME))

echo -e "\n⏱️ 実行時間: ${TOTAL}秒" | tee -a "$OUTPUT_FILE"
echo "📄 → $OUTPUT_FILE"