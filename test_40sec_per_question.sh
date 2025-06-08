#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="test_40sec_results_${TIMESTAMP}.txt"

# 開始時刻
START_TIME=$(date +%s)

# 全モデルをテスト
MODELS=(
  "gemma3:4b"
  "qwen3:latest"
  "llava:7b"
  "jaahas/qwen3-abliterated:0.6b"
)

# 3つの質問
declare -A QUESTIONS=(
  ["Q1"]="10 + 15 = ?"
  ["Q2"]="日本で一番高い山は何ですか？"
  ["Q3"]="「Good morning」を日本語に翻訳してください。"
)

# 期待される回答
declare -A EXPECTED=(
  ["Q1"]="25"
  ["Q2"]="富士山"
  ["Q3"]="おはよう"
)

{
  echo "🚀 モデルテスト (1問40秒制限)"
  echo "開始時刻: $(date)"
  echo "=================================="
  
  # 結果集計用
  declare -A MODEL_SCORES
  declare -A MODEL_TIMES
  declare -A MODEL_DETAILS
  
  for MODEL in "${MODELS[@]}"; do
    echo -e "\n📦 MODEL: $MODEL"
    echo "---"
    
    MODEL_START=$(date +%s)
    SCORE=0
    DETAILS=""
    TOTAL_Q_TIME=0
    
    for KEY in "${!QUESTIONS[@]}"; do
      Q="${QUESTIONS[$KEY]}"
      echo -e "\n🔍 $KEY: $Q"
      
      Q_START=$(date +%s)
      
      # 1問あたり最大40秒
      RESP=$(curl -s --max-time 40 http://localhost:11434/api/generate \
        -d "{\"model\":\"$MODEL\",\"prompt\":\"$Q 簡潔に答えてください。\",\"stream\":false,\"options\":{\"temperature\":0.1,\"num_predict\":50}}" \
        2>/dev/null | jq -r '.response // "TIMEOUT"' 2>/dev/null || echo "ERROR")
      
      Q_END=$(date +%s)
      Q_TIME=$((Q_END - Q_START))
      TOTAL_Q_TIME=$((TOTAL_Q_TIME + Q_TIME))
      
      # 応答を整形
      RESP_CLEAN=$(echo "$RESP" | tr '\n' ' ' | sed 's/  */ /g' | sed 's/^ *//;s/ *$//')
      RESP_SHORT="${RESP_CLEAN:0:50}"
      
      # 評価
      if [[ "$RESP" =~ ${EXPECTED[$KEY]} ]]; then
        echo "✅ 正解: $RESP_SHORT (${Q_TIME}秒)"
        ((SCORE++))
        DETAILS+="$KEY:✅(${Q_TIME}s) "
      else
        echo "❌ 不正解: $RESP_SHORT (${Q_TIME}秒)"
        DETAILS+="$KEY:❌(${Q_TIME}s) "
      fi
      
      # 40秒超過チェック
      if [ $Q_TIME -ge 40 ]; then
        echo "⚠️  40秒タイムアウト!"
      fi
    done
    
    MODEL_END=$(date +%s)
    MODEL_TIME=$((MODEL_END - MODEL_START))
    AVG_TIME=$((TOTAL_Q_TIME / 3))
    
    PERCENTAGE=$(echo "scale=0; $SCORE * 100 / ${#QUESTIONS[@]}" | bc)
    
    echo -e "\n📊 結果:"
    echo "スコア: $SCORE/${#QUESTIONS[@]} (${PERCENTAGE}%)"
    echo "合計時間: ${MODEL_TIME}秒 (平均: ${AVG_TIME}秒/問)"
    echo "詳細: $DETAILS"
    
    # 結果を保存
    MODEL_SCORES[$MODEL]="$SCORE/${#QUESTIONS[@]} (${PERCENTAGE}%)"
    MODEL_TIMES[$MODEL]="${MODEL_TIME}秒 (平均${AVG_TIME}秒)"
    MODEL_DETAILS[$MODEL]="$DETAILS"
  done
  
  END_TIME=$(date +%s)
  TOTAL_TIME=$((END_TIME - START_TIME))
  
  echo -e "\n╔════════════════════════════════════════╗"
  echo "║          最終結果サマリー              ║"
  echo "╚════════════════════════════════════════╝"
  
  echo -e "\n📊 モデル別スコア:"
  echo "----------------------------------------"
  for MODEL in "${!MODEL_SCORES[@]}"; do
    printf "%-25s : %s\n" "$MODEL" "${MODEL_SCORES[$MODEL]}"
  done
  
  echo -e "\n⏱️  モデル別時間:"
  echo "----------------------------------------"
  for MODEL in "${!MODEL_TIMES[@]}"; do
    printf "%-25s : %s\n" "$MODEL" "${MODEL_TIMES[$MODEL]}"
  done
  
  echo -e "\n📋 詳細結果:"
  echo "----------------------------------------"
  for MODEL in "${!MODEL_DETAILS[@]}"; do
    printf "%-25s : %s\n" "$MODEL" "${MODEL_DETAILS[$MODEL]}"
  done
  
  echo -e "\n⏱️  総実行時間: ${TOTAL_TIME}秒"
  
  # ベストモデル判定
  echo -e "\n🏆 評価:"
  for MODEL in "${!MODEL_SCORES[@]}"; do
    SCORE=$(echo "${MODEL_SCORES[$MODEL]}" | cut -d'/' -f1)
    case $SCORE in
      3) echo "⭐ $MODEL - 完璧！全問正解" ;;
      2) echo "👍 $MODEL - 良好 (2/3正解)" ;;
      1) echo "📌 $MODEL - 要改善 (1/3正解)" ;;
      0) echo "⚠️  $MODEL - 要調整 (0/3正解)" ;;
    esac
  done
  
  echo -e "\n終了時刻: $(date)"
} | tee "$OUTPUT_FILE"

echo -e "\n📄 結果保存: $OUTPUT_FILE"