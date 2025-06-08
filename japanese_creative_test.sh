#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="japanese_creative_results_${TIMESTAMP}.txt"

# 開始時刻
START_TIME=$(date +%s)

# 全モデルをテスト
MODELS=(
  "gemma3:4b"
  "qwen3:latest"
  "llama3.2:1b"
  "phi3:mini"
  "llava:7b"
)

# 日本語理解・創造的タスク
declare -A JAPANESE_TASKS=(
  ["J1"]="「春」をテーマに俳句を1つ作ってください"
  ["J2"]="「AI」について50文字以内で説明してください"
  ["J3"]="「笑う」の敬語は何ですか？"
  ["J4"]="「ありがとう」を3つの異なる敬語レベルで表現してください"
)

# 期待される要素
declare -A JAPANESE_EXPECTED=(
  ["J1"]="五七五|5.*7.*5|春|桜|花"
  ["J2"]="人工知能|コンピュータ|機械|学習|データ"
  ["J3"]="お笑いになる|笑われる|微笑まれる"
  ["J4"]="ありがとうございます|感謝|恐れ入ります|恐縮"
)

{
  echo "🎌 日本語理解・創造性テスト"
  echo "開始時刻: $(date)"
  echo "================================"
  echo ""
  
  # 結果集計用
  declare -A MODEL_SCORES
  declare -A CREATIVITY_SCORES
  
  for MODEL in "${MODELS[@]}"; do
    echo "📦 MODEL: $MODEL"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    MODEL_START=$(date +%s)
    SCORE=0
    CREATIVITY=0
    
    for KEY in "${!JAPANESE_TASKS[@]}"; do
      TASK="${JAPANESE_TASKS[$KEY]}"
      echo ""
      echo "📝 $KEY: $TASK"
      
      Q_START=$(date +%s)
      
      # API呼び出し
      RESP=$(curl -s --max-time 20 http://localhost:11434/api/generate \
        -d "{\"model\":\"$MODEL\",\"prompt\":\"$TASK\",\"stream\":false,\"options\":{\"temperature\":0.5,\"num_predict\":100}}" \
        2>/dev/null | jq -r '.response // "TIMEOUT"' 2>/dev/null || echo "ERROR")
      
      Q_END=$(date +%s)
      Q_TIME=$((Q_END - Q_START))
      
      # <think>タグを除去して整形
      RESP_CLEAN=$(echo "$RESP" | sed 's/<think>.*<\/think>//g' | sed 's/<think>.*//g' | tr '\n' ' ')
      RESP_SHORT="${RESP_CLEAN:0:100}"
      
      # 評価
      if [[ "$RESP_CLEAN" =~ ${JAPANESE_EXPECTED[$KEY]} ]]; then
        echo "✅ 適切: $RESP_SHORT... (${Q_TIME}秒)"
        ((SCORE++))
        
        # 創造性評価（俳句の場合）
        if [[ "$KEY" == "J1" ]]; then
          if [[ "$RESP_CLEAN" =~ (春|桜|花|風|暖) ]]; then
            ((CREATIVITY++))
            echo "   🌸 季語使用: ✓"
          fi
          if [[ "$RESP_CLEAN" =~ [0-9].*[0-9].*[0-9] ]] || [[ "$RESP_CLEAN" =~ 五.*七.*五 ]]; then
            ((CREATIVITY++))
            echo "   📏 形式説明: ✓"
          fi
        fi
        
        # 敬語レベル評価
        if [[ "$KEY" == "J4" ]]; then
          POLITE_COUNT=$(echo "$RESP_CLEAN" | grep -o -E "ありがとう|感謝|恐れ入|恐縮|お礼" | wc -l)
          if [ $POLITE_COUNT -ge 3 ]; then
            ((CREATIVITY++))
            echo "   🎯 3レベル達成: ✓"
          fi
        fi
      else
        echo "❌ 不適切: $RESP_SHORT... (${Q_TIME}秒)"
      fi
    done
    
    MODEL_END=$(date +%s)
    MODEL_TIME=$((MODEL_END - MODEL_START))
    
    PERCENTAGE=$(echo "scale=0; $SCORE * 100 / ${#JAPANESE_TASKS[@]}" | bc)
    
    echo ""
    echo "📊 結果:"
    echo "基本スコア: $SCORE/${#JAPANESE_TASKS[@]} (${PERCENTAGE}%)"
    echo "創造性ポイント: ${CREATIVITY}"
    echo "実行時間: ${MODEL_TIME}秒"
    echo ""
    
    MODEL_SCORES[$MODEL]="$SCORE/${#JAPANESE_TASKS[@]} (${PERCENTAGE}%)"
    CREATIVITY_SCORES[$MODEL]="${CREATIVITY}pts"
  done
  
  END_TIME=$(date +%s)
  TOTAL_TIME=$((END_TIME - START_TIME))
  
  echo "╔════════════════════════════════════════╗"
  echo "║    日本語理解・創造性テスト結果        ║"
  echo "╚════════════════════════════════════════╝"
  echo ""
  
  echo "📊 モデル別スコア:"
  for MODEL in "${!MODEL_SCORES[@]}"; do
    printf "%-20s : %s (創造性: %s)\n" "$MODEL" "${MODEL_SCORES[$MODEL]}" "${CREATIVITY_SCORES[$MODEL]}"
  done
  
  echo ""
  echo "⏱️ 総実行時間: ${TOTAL_TIME}秒"
  echo ""
  echo "🎨 評価ポイント:"
  echo "• 俳句: 季語の使用、形式の理解"
  echo "• 説明: 簡潔性と正確性"
  echo "• 敬語: レベルの多様性"
  echo ""
  echo "終了時刻: $(date)"
} | tee "$OUTPUT_FILE"

echo ""
echo "📄 結果保存完了: $OUTPUT_FILE"