#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="quick_advanced_results_${TIMESTAMP}.txt"

# 開始時刻
START_TIME=$(date +%s)

# 2モデルで高度な問題をテスト
MODELS=(
  "gemma3:4b"
  "qwen3:latest"
)

echo "🎯 高度な問題クイックテスト" | tee "$OUTPUT_FILE"
echo "========================" | tee -a "$OUTPUT_FILE"
echo "" | tee -a "$OUTPUT_FILE"

for MODEL in "${MODELS[@]}"; do
  echo "📦 MODEL: $MODEL" | tee -a "$OUTPUT_FILE"
  echo "---" | tee -a "$OUTPUT_FILE"
  
  # Q1: フィボナッチ
  echo "Q1: フィボナッチ数列の最初の8個は？" | tee -a "$OUTPUT_FILE"
  Q_START=$(date +%s)
  RESP=$(curl -s --max-time 20 http://localhost:11434/api/generate \
    -d "{\"model\":\"$MODEL\",\"prompt\":\"フィボナッチ数列の最初の8個を答えてください。数字のみ。\",\"stream\":false,\"options\":{\"temperature\":0.1,\"num_predict\":100}}" \
    2>/dev/null | jq -r '.response // "ERROR"' 2>/dev/null || echo "TIMEOUT")
  Q_END=$(date +%s)
  Q_TIME=$((Q_END - Q_START))
  
  RESP_SHORT=$(echo "$RESP" | tr '\n' ' ' | cut -c1-80)
  if [[ "$RESP" =~ (0.*1.*1.*2.*3.*5.*8.*13|1.*1.*2.*3.*5.*8.*13.*21) ]]; then
    echo "✅ 正解: $RESP_SHORT (${Q_TIME}秒)" | tee -a "$OUTPUT_FILE"
  else
    echo "❌ 不正解: $RESP_SHORT (${Q_TIME}秒)" | tee -a "$OUTPUT_FILE"
  fi
  
  # Q2: 素数判定
  echo "" | tee -a "$OUTPUT_FILE"
  echo "Q2: 97は素数ですか？理由も含めて答えてください。" | tee -a "$OUTPUT_FILE"
  Q_START=$(date +%s)
  RESP=$(curl -s --max-time 20 http://localhost:11434/api/generate \
    -d "{\"model\":\"$MODEL\",\"prompt\":\"97は素数ですか？理由も含めて簡潔に答えてください。\",\"stream\":false,\"options\":{\"temperature\":0.1,\"num_predict\":100}}" \
    2>/dev/null | jq -r '.response // "ERROR"' 2>/dev/null || echo "TIMEOUT")
  Q_END=$(date +%s)
  Q_TIME=$((Q_END - Q_START))
  
  RESP_SHORT=$(echo "$RESP" | tr '\n' ' ' | cut -c1-80)
  if [[ "$RESP" =~ (素数|prime) ]] && [[ "$RESP" =~ (はい|Yes|yes|である) ]]; then
    echo "✅ 正解: $RESP_SHORT (${Q_TIME}秒)" | tee -a "$OUTPUT_FILE"
  else
    echo "❌ 不正解: $RESP_SHORT (${Q_TIME}秒)" | tee -a "$OUTPUT_FILE"
  fi
  
  # Q3: コード理解
  echo "" | tee -a "$OUTPUT_FILE"
  echo "Q3: Pythonで[1,2,3,4,5]の合計を求めるコードを書いてください。" | tee -a "$OUTPUT_FILE"
  Q_START=$(date +%s)
  RESP=$(curl -s --max-time 20 http://localhost:11434/api/generate \
    -d "{\"model\":\"$MODEL\",\"prompt\":\"Pythonで[1,2,3,4,5]の合計を求めるコードを書いてください。\",\"stream\":false,\"options\":{\"temperature\":0.1,\"num_predict\":100}}" \
    2>/dev/null | jq -r '.response // "ERROR"' 2>/dev/null || echo "TIMEOUT")
  Q_END=$(date +%s)
  Q_TIME=$((Q_END - Q_START))
  
  RESP_SHORT=$(echo "$RESP" | tr '\n' ' ' | cut -c1-80)
  if [[ "$RESP" =~ (sum|合計) ]]; then
    echo "✅ 正解: $RESP_SHORT (${Q_TIME}秒)" | tee -a "$OUTPUT_FILE"
  else
    echo "❌ 不正解: $RESP_SHORT (${Q_TIME}秒)" | tee -a "$OUTPUT_FILE"
  fi
  
  echo "" | tee -a "$OUTPUT_FILE"
done

END_TIME=$(date +%s)
TOTAL=$((END_TIME - START_TIME))

echo "⏱️ 総実行時間: ${TOTAL}秒" | tee -a "$OUTPUT_FILE"
echo "📄 → $OUTPUT_FILE"