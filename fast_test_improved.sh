#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="fast_test_results_${TIMESTAMP}.txt"

# 開始時刻
START_TIME=$(date +%s)

# 利用可能なモデル（高速なものから）
MODELS=(
  "jaahas/qwen3-abliterated:0.6b"
  "gemma3:4b"
  "qwen3:latest"
)

# シンプルな質問（高速化のため）
declare -A QUESTIONS=(
  ["Q1"]="1+1="
  ["Q2"]="Tokyo is the capital of"
  ["Q3"]="2x3="
)

# 期待される回答
declare -A EXPECTED=(
  ["Q1"]="2"
  ["Q2"]="Japan|日本"
  ["Q3"]="6"
)

{
  echo "🚀 高速モデルテスト (30秒以内目標)"
  echo "開始時刻: $(date)"
  echo "=================================="
  
  # 結果サマリー用
  declare -A MODEL_RESULTS
  
  # 各モデルをテスト
  for MODEL in "${MODELS[@]}"; do
    echo -e "\n📦 MODEL: $MODEL"
    echo "---"
    
    MODEL_START=$(date +%s)
    SCORE=0
    FAILED_QUESTIONS=""
    SUCCESS_QUESTIONS=""
    
    for KEY in "${!QUESTIONS[@]}"; do
      Q="${QUESTIONS[$KEY]}"
      
      # curlで実行（タイムアウト10秒）
      RESP=$(curl -s --max-time 10 http://localhost:11434/api/generate \
        -d "{\"model\":\"$MODEL\",\"prompt\":\"$Q\",\"stream\":false,\"options\":{\"temperature\":0.1,\"num_predict\":10}}" \
        2>/dev/null | jq -r '.response // "TIMEOUT"' 2>/dev/null || echo "CURL_ERROR")
      
      # 応答を1行に短縮
      RESP_SHORT=$(echo "$RESP" | tr '\n' ' ' | sed 's/  */ /g' | cut -c1-30)
      
      # 評価
      if [[ "$RESP" =~ ${EXPECTED[$KEY]} ]]; then
        echo "✅ $KEY: $Q → $RESP_SHORT"
        ((SCORE++))
        SUCCESS_QUESTIONS+="$KEY "
      else
        echo "❌ $KEY: $Q → $RESP_SHORT"
        FAILED_QUESTIONS+="$KEY($RESP_SHORT) "
      fi
    done
    
    MODEL_END=$(date +%s)
    MODEL_TIME=$((MODEL_END - MODEL_START))
    
    PERCENTAGE=$(echo "scale=0; $SCORE * 100 / ${#QUESTIONS[@]}" | bc)
    echo "📊 スコア: $SCORE/${#QUESTIONS[@]} (${PERCENTAGE}%) - ${MODEL_TIME}秒"
    
    # 結果を保存
    MODEL_RESULTS[$MODEL]="Score:$SCORE/${#QUESTIONS[@]}(${PERCENTAGE}%) Time:${MODEL_TIME}s"
    
    if [ -n "$FAILED_QUESTIONS" ]; then
      echo "🔴 失敗: $FAILED_QUESTIONS"
    fi
    if [ -n "$SUCCESS_QUESTIONS" ]; then
      echo "🟢 成功: $SUCCESS_QUESTIONS"
    fi
    
    # 30秒チェック
    CURRENT_TIME=$(date +%s)
    ELAPSED=$((CURRENT_TIME - START_TIME))
    if [ $ELAPSED -gt 25 ]; then
      echo "⚠️  時間制限が近づいています。残りのモデルをスキップします。"
      break
    fi
  done
  
  END_TIME=$(date +%s)
  TOTAL_TIME=$((END_TIME - START_TIME))
  
  echo -e "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📋 テスト結果サマリー"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  for MODEL in "${!MODEL_RESULTS[@]}"; do
    echo "$MODEL: ${MODEL_RESULTS[$MODEL]}"
  done
  
  echo ""
  echo "⏱️  総実行時間: ${TOTAL_TIME}秒"
  
  if [ $TOTAL_TIME -gt 30 ]; then
    echo "⚠️  30秒を超過しました！"
    echo ""
    echo "📋 実装済み改善策:"
    echo "✓ トークン数を10に削減"
    echo "✓ 簡単な質問に変更"  
    echo "✓ 温度を0.1に設定"
    echo "✓ 25秒で早期終了"
    echo ""
    echo "📋 追加改善案:"
    echo "• より小さいモデルのみ使用"
    echo "• 質問数を削減"
    echo "• 並列処理の実装"
  else
    echo "✅ 30秒以内に完了しました！"
  fi
  
  echo -e "\n終了時刻: $(date)"
} | tee "$OUTPUT_FILE"

echo -e "\n📄 結果は $OUTPUT_FILE に保存されました"