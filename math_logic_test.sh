#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="math_logic_results_${TIMESTAMP}.txt"

# 開始時刻
START_TIME=$(date +%s)

# 全モデルをテスト
MODELS=(
  "gemma3:4b"
  "qwen3:latest"
  "llava:7b"
  "llama3.2:1b"
  "phi3:mini"
  "jaahas/qwen3-abliterated:0.6b"
)

# 数学・論理問題
declare -A MATH_QUESTIONS=(
  ["M1"]="25 × 4 = ?"
  ["M2"]="次の数列の次の数は？ 2, 4, 8, 16, ?"
  ["M3"]="円の面積の公式は？"
  ["M4"]="100の20%は？"
  ["M5"]="もし全ての鳥が飛べて、ペンギンは鳥なら、ペンギンは飛べる。この推論は正しい？"
)

# 期待される回答のキーワード
declare -A MATH_EXPECTED=(
  ["M1"]="100"
  ["M2"]="32"
  ["M3"]="πr|πr²|パイ.*r|円周率"
  ["M4"]="20"
  ["M5"]="いいえ|間違|誤り|false|ペンギンは飛べない"
)

{
  echo "🧮 数学・論理問題テスト"
  echo "開始時刻: $(date)"
  echo "================================"
  echo ""
  
  # 結果集計用
  declare -A MODEL_SCORES
  declare -A RESPONSE_TIMES
  declare -A ANSWER_DETAILS
  
  for MODEL in "${MODELS[@]}"; do
    echo "📦 MODEL: $MODEL"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    MODEL_START=$(date +%s)
    SCORE=0
    TOTAL_TIME=0
    DETAILS=""
    
    for KEY in "${!MATH_QUESTIONS[@]}"; do
      Q="${MATH_QUESTIONS[$KEY]}"
      echo ""
      echo "🔢 $KEY: $Q"
      
      Q_START=$(date +%s)
      
      # API呼び出し（最大15秒）
      RESP=$(curl -s --max-time 15 http://localhost:11434/api/generate \
        -d "{\"model\":\"$MODEL\",\"prompt\":\"$Q 答えのみ簡潔に。\",\"stream\":false,\"options\":{\"temperature\":0.1,\"num_predict\":50}}" \
        2>/dev/null | jq -r '.response // "TIMEOUT"' 2>/dev/null || echo "ERROR")
      
      Q_END=$(date +%s)
      Q_TIME=$((Q_END - Q_START))
      TOTAL_TIME=$((TOTAL_TIME + Q_TIME))
      
      # 応答を整形（<think>タグを除去）
      RESP_CLEAN=$(echo "$RESP" | sed 's/<think>.*<\/think>//g' | sed 's/<think>.*//g' | tr '\n' ' ' | sed 's/  */ /g')
      RESP_SHORT="${RESP_CLEAN:0:60}"
      
      # 評価
      if [[ "$RESP_CLEAN" =~ ${MATH_EXPECTED[$KEY]} ]]; then
        echo "✅ 正解: $RESP_SHORT (${Q_TIME}秒)"
        ((SCORE++))
        DETAILS+="$KEY:✅ "
      else
        echo "❌ 不正解: $RESP_SHORT (${Q_TIME}秒)"
        DETAILS+="$KEY:❌ "
      fi
    done
    
    MODEL_END=$(date +%s)
    MODEL_TIME=$((MODEL_END - MODEL_START))
    AVG_TIME=$((TOTAL_TIME / ${#MATH_QUESTIONS[@]}))
    
    PERCENTAGE=$(echo "scale=0; $SCORE * 100 / ${#MATH_QUESTIONS[@]}" | bc)
    
    echo ""
    echo "📊 結果:"
    echo "スコア: $SCORE/${#MATH_QUESTIONS[@]} (${PERCENTAGE}%)"
    echo "合計時間: ${MODEL_TIME}秒 (平均: ${AVG_TIME}秒/問)"
    echo "詳細: $DETAILS"
    echo ""
    
    # 結果を保存
    MODEL_SCORES[$MODEL]="$SCORE/${#MATH_QUESTIONS[@]} (${PERCENTAGE}%)"
    RESPONSE_TIMES[$MODEL]="${AVG_TIME}秒/問"
    ANSWER_DETAILS[$MODEL]="$DETAILS"
  done
  
  END_TIME=$(date +%s)
  TOTAL_TIME=$((END_TIME - START_TIME))
  
  echo "╔════════════════════════════════════════╗"
  echo "║        数学・論理テスト結果            ║"
  echo "╚════════════════════════════════════════╝"
  echo ""
  
  echo "📊 モデル別スコアランキング:"
  echo "----------------------------"
  # スコアでソート
  for MODEL in "${!MODEL_SCORES[@]}"; do
    echo "$MODEL|${MODEL_SCORES[$MODEL]}"
  done | sort -t'|' -k2 -r | while IFS='|' read -r MODEL SCORE; do
    printf "%-25s : %s\n" "$MODEL" "$SCORE"
  done
  
  echo ""
  echo "⏱️ 平均応答時間:"
  echo "----------------"
  for MODEL in "${!RESPONSE_TIMES[@]}"; do
    printf "%-25s : %s\n" "$MODEL" "${RESPONSE_TIMES[$MODEL]}"
  done
  
  echo ""
  echo "📋 問題別正答状況:"
  echo "-----------------"
  for MODEL in "${!ANSWER_DETAILS[@]}"; do
    printf "%-25s : %s\n" "$MODEL" "${ANSWER_DETAILS[$MODEL]}"
  done
  
  echo ""
  echo "⏱️ 総実行時間: ${TOTAL_TIME}秒"
  echo ""
  echo "🏆 総合評価:"
  for MODEL in "${!MODEL_SCORES[@]}"; do
    SCORE=$(echo "${MODEL_SCORES[$MODEL]}" | cut -d'/' -f1)
    case $SCORE in
      5) echo "⭐⭐⭐ $MODEL - 完璧！全問正解" ;;
      4) echo "⭐⭐ $MODEL - 優秀 (4/5正解)" ;;
      3) echo "⭐ $MODEL - 良好 (3/5正解)" ;;
      2) echo "📌 $MODEL - 可 (2/5正解)" ;;
      1) echo "⚠️ $MODEL - 要改善 (1/5正解)" ;;
      0) echo "❌ $MODEL - 要調整 (0/5正解)" ;;
    esac
  done
  
  echo ""
  echo "終了時刻: $(date)"
} | tee "$OUTPUT_FILE"

echo ""
echo "📄 結果保存完了: $OUTPUT_FILE"