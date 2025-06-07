#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="quick_comparison_results_${TIMESTAMP}.txt"

# 開始時刻
START_TIME=$(date +%s)

# 主要モデルを比較
MODELS=(
  "gemma3:4b"
  "qwen3:latest"
  "llama3.2:1b"
  "phi3:mini"
)

{
  echo "⚡ クイック比較テスト"
  echo "開始時刻: $(date)"
  echo "===================="
  echo ""
  
  # 各モデルで同じ5つの質問
  echo "【テスト内容】"
  echo "1. 算数: 15 + 28 = ?"
  echo "2. 知識: 富士山の高さは？"
  echo "3. 翻訳: 「Thank you」を日本語で"
  echo "4. 論理: 「全ての猫は動物、タマは猫」ならタマは？"
  echo "5. コード: print('Hello')の出力は？"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # 結果記録用
  declare -A SCORES
  declare -A TIMES
  
  for MODEL in "${MODELS[@]}"; do
    echo ""
    echo "📦 $MODEL"
    MODEL_START=$(date +%s)
    CORRECT=0
    
    # Q1: 算数
    R1=$(curl -s --max-time 10 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"15 + 28 = ? 数字のみ答えて\",\"stream\":false,\"options\":{\"temperature\":0,\"num_predict\":10}}" \
      2>/dev/null | jq -r '.response // "ERR"' | sed 's/<think>.*//g' | tr -d '\n' | sed 's/[^0-9]//g')
    
    if [[ "$R1" == "43" ]]; then
      echo "Q1: ✅ $R1"
      ((CORRECT++))
    else
      echo "Q1: ❌ $R1"
    fi
    
    # Q2: 知識
    R2=$(curl -s --max-time 10 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"富士山の高さは何メートル？数字のみ\",\"stream\":false,\"options\":{\"temperature\":0,\"num_predict\":20}}" \
      2>/dev/null | jq -r '.response // "ERR"' | sed 's/<think>.*//g')
    
    if [[ "$R2" =~ 3776 ]]; then
      echo "Q2: ✅ 3776m"
      ((CORRECT++))
    else
      R2_SHORT=$(echo "$R2" | tr '\n' ' ' | cut -c1-20)
      echo "Q2: ❌ $R2_SHORT"
    fi
    
    # Q3: 翻訳
    R3=$(curl -s --max-time 10 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"Thank youを日本語で\",\"stream\":false,\"options\":{\"temperature\":0,\"num_predict\":20}}" \
      2>/dev/null | jq -r '.response // "ERR"' | sed 's/<think>.*//g')
    
    if [[ "$R3" =~ (ありがとう|有難う) ]]; then
      echo "Q3: ✅ ありがとう"
      ((CORRECT++))
    else
      R3_SHORT=$(echo "$R3" | tr '\n' ' ' | cut -c1-20)
      echo "Q3: ❌ $R3_SHORT"
    fi
    
    # Q4: 論理
    R4=$(curl -s --max-time 10 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"全ての猫は動物です。タマは猫です。タマは何ですか？一言で\",\"stream\":false,\"options\":{\"temperature\":0,\"num_predict\":20}}" \
      2>/dev/null | jq -r '.response // "ERR"' | sed 's/<think>.*//g')
    
    if [[ "$R4" =~ (動物|animal) ]]; then
      echo "Q4: ✅ 動物"
      ((CORRECT++))
    else
      R4_SHORT=$(echo "$R4" | tr '\n' ' ' | cut -c1-20)
      echo "Q4: ❌ $R4_SHORT"
    fi
    
    # Q5: コード
    R5=$(curl -s --max-time 10 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"Pythonでprint('Hello')を実行すると何が出力される？\",\"stream\":false,\"options\":{\"temperature\":0,\"num_predict\":20}}" \
      2>/dev/null | jq -r '.response // "ERR"' | sed 's/<think>.*//g')
    
    if [[ "$R5" =~ Hello ]]; then
      echo "Q5: ✅ Hello"
      ((CORRECT++))
    else
      R5_SHORT=$(echo "$R5" | tr '\n' ' ' | cut -c1-20)
      echo "Q5: ❌ $R5_SHORT"
    fi
    
    MODEL_END=$(date +%s)
    MODEL_TIME=$((MODEL_END - MODEL_START))
    
    PERCENTAGE=$(echo "scale=0; $CORRECT * 100 / 5" | bc)
    echo "━━━━━━━━━━━━━━━━━━━"
    echo "スコア: $CORRECT/5 (${PERCENTAGE}%) - ${MODEL_TIME}秒"
    
    SCORES[$MODEL]="$CORRECT/5 (${PERCENTAGE}%)"
    TIMES[$MODEL]="${MODEL_TIME}秒"
  done
  
  END_TIME=$(date +%s)
  TOTAL_TIME=$((END_TIME - START_TIME))
  
  echo ""
  echo "╔════════════════════════════════════════╗"
  echo "║         クイック比較結果               ║"
  echo "╚════════════════════════════════════════╝"
  echo ""
  
  echo "📊 最終スコア:"
  for MODEL in "${!SCORES[@]}"; do
    printf "%-15s : %-15s (時間: %s)\n" "$MODEL" "${SCORES[$MODEL]}" "${TIMES[$MODEL]}"
  done
  
  echo ""
  echo "⏱️ 総実行時間: ${TOTAL_TIME}秒"
  echo ""
  
  # ベストモデル判定
  echo "🏆 ランキング:"
  for MODEL in "${!SCORES[@]}"; do
    SCORE=$(echo "${SCORES[$MODEL]}" | cut -d'/' -f1)
    echo "$SCORE $MODEL"
  done | sort -rn | while read SCORE MODEL; do
    case $SCORE in
      5) echo "🥇 $MODEL - パーフェクト!" ;;
      4) echo "🥈 $MODEL - 優秀" ;;
      3) echo "🥉 $MODEL - 良好" ;;
      *) echo "📌 $MODEL - 要改善" ;;
    esac
  done
  
  echo ""
  echo "終了時刻: $(date)"
} | tee "$OUTPUT_FILE"

echo ""
echo "📄 結果: $OUTPUT_FILE"