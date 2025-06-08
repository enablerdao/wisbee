#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="fast_test_results_${TIMESTAMP}.txt"

# 開始時刻
START_TIME=$(date +%s)

# 利用可能なモデル
MODELS=(
  "gemma3:4b"
  "qwen3:latest"
  "llava:7b"
  "jaahas/qwen3-abliterated:0.6b"
)

# シンプルな質問（高速化のため）
declare -A QUESTIONS=(
  ["Q1"]="1+1は何ですか？"
  ["Q2"]="日本の首都は？"
  ["Q3"]="Hello を日本語で？"
)

# 期待される回答
declare -A EXPECTED=(
  ["Q1"]="2"
  ["Q2"]="東京"
  ["Q3"]="こんにちは|ハロー"
)

{
  echo "🚀 高速モデルテスト (30秒以内目標)"
  echo "開始時刻: $(date)"
  echo "="
  
  # 各モデルをテスト
  for MODEL in "${MODELS[@]}"; do
    echo -e "\n📦 MODEL: $MODEL"
    echo "---"
    
    MODEL_START=$(date +%s)
    SCORE=0
    FAILED_QUESTIONS=""
    
    for KEY in "${!QUESTIONS[@]}"; do
      Q="${QUESTIONS[$KEY]}"
      
      # 10秒タイムアウトで実行
      RESP=$(timeout 10 curl -s http://localhost:11434/api/generate \
        -d "{\"model\":\"$MODEL\",\"prompt\":\"$Q 簡潔に答えてください。\",\"stream\":false,\"options\":{\"temperature\":0.1,\"num_predict\":20}}" \
        2>/dev/null | jq -r '.response // "TIMEOUT"' 2>/dev/null || echo "ERROR")
      
      # 応答を1行に短縮
      RESP_SHORT=$(echo "$RESP" | tr '\n' ' ' | cut -c1-50)
      
      # 評価
      if [[ "$RESP" =~ ${EXPECTED[$KEY]} ]]; then
        echo "✅ $KEY: $Q → $RESP_SHORT"
        ((SCORE++))
      else
        echo "❌ $KEY: $Q → $RESP_SHORT"
        FAILED_QUESTIONS+="$KEY:$RESP_SHORT "
      fi
    done
    
    MODEL_END=$(date +%s)
    MODEL_TIME=$((MODEL_END - MODEL_START))
    
    PERCENTAGE=$(echo "scale=0; $SCORE * 100 / ${#QUESTIONS[@]}" | bc)
    echo "📊 スコア: $SCORE/${#QUESTIONS[@]} (${PERCENTAGE}%) - ${MODEL_TIME}秒"
    
    if [ -n "$FAILED_QUESTIONS" ]; then
      echo "🔴 失敗: $FAILED_QUESTIONS"
    fi
  done
  
  END_TIME=$(date +%s)
  TOTAL_TIME=$((END_TIME - START_TIME))
  
  echo -e "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "⏱️  総実行時間: ${TOTAL_TIME}秒"
  
  if [ $TOTAL_TIME -gt 30 ]; then
    echo "⚠️  30秒を超過しました！"
    echo ""
    echo "📋 改善提案:"
    echo "1. より少ないトークン数 (num_predict) に削減"
    echo "2. 並列実行の実装"
    echo "3. ストリーミングを無効化済み (stream:false)"
    echo "4. タイムアウトを短縮 (現在10秒)"
    echo "5. より簡単な質問に変更"
  else
    echo "✅ 30秒以内に完了しました！"
  fi
  
  echo -e "\n終了時刻: $(date)"
} | tee "$OUTPUT_FILE"

echo -e "\n📄 結果は $OUTPUT_FILE に保存されました"