#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="reasoning_chain_results_${TIMESTAMP}.txt"

# 開始時刻
START_TIME=$(date +%s)

# テスト対象モデル
MODELS=(
  "gemma3:4b"
  "qwen3:latest"
  "phi3:mini"
  "llama3.2:1b"
)

# 推論チェーン問題
declare -A REASONING_TASKS=(
  ["R1"]="太郎は花子より背が高い。花子は次郎より背が高い。誰が一番背が高い？"
  ["R2"]="赤いボールが3個、青いボールが5個あります。ボールを2個取りました。残りは何個？"
  ["R3"]="月曜日の3日後は何曜日？"
  ["R4"]="AはBの2倍、Bは10です。Aはいくつ？"
)

# 期待される回答
declare -A REASONING_EXPECTED=(
  ["R1"]="太郎"
  ["R2"]="6"
  ["R3"]="木曜"
  ["R4"]="20"
)

{
  echo "🧠 推論チェーンテスト"
  echo "開始時刻: $(date)"
  echo "====================="
  echo ""
  echo "【推論の連鎖を測定】"
  echo ""
  
  # 結果集計
  declare -A MODEL_SCORES
  declare -A REASONING_QUALITY
  
  for MODEL in "${MODELS[@]}"; do
    echo "📦 MODEL: $MODEL"
    echo "---"
    
    MODEL_START=$(date +%s)
    SCORE=0
    EXPLANATION_QUALITY=0
    
    for KEY in "${!REASONING_TASKS[@]}"; do
      TASK="${REASONING_TASKS[$KEY]}"
      echo ""
      echo "🔍 $KEY: $TASK"
      
      # ステップバイステップで考えるよう促す
      PROMPT="$TASK 理由も含めて答えてください。"
      
      Q_START=$(date +%s)
      
      RESP=$(curl -s --max-time 15 http://localhost:11434/api/generate \
        -d "{\"model\":\"$MODEL\",\"prompt\":\"$PROMPT\",\"stream\":false,\"options\":{\"temperature\":0.2,\"num_predict\":100}}" \
        2>/dev/null | jq -r '.response // "TIMEOUT"' 2>/dev/null || echo "ERROR")
      
      Q_END=$(date +%s)
      Q_TIME=$((Q_END - Q_START))
      
      # <think>タグを除去
      RESP_CLEAN=$(echo "$RESP" | sed 's/<think>.*<\/think>//g' | sed 's/<think>.*//g')
      RESP_SHORT=$(echo "$RESP_CLEAN" | tr '\n' ' ' | cut -c1-80)
      
      # 正解チェック
      if [[ "$RESP_CLEAN" =~ ${REASONING_EXPECTED[$KEY]} ]]; then
        echo "✅ 正解: $RESP_SHORT... (${Q_TIME}秒)"
        ((SCORE++))
        
        # 説明の質を評価
        case $KEY in
          R1)
            if [[ "$RESP_CLEAN" =~ (推移|transitive|順序) ]]; then
              ((EXPLANATION_QUALITY++))
              echo "   💡 推論説明あり"
            fi
            ;;
          R2)
            if [[ "$RESP_CLEAN" =~ (3.*5.*8|8.*2.*6) ]]; then
              ((EXPLANATION_QUALITY++))
              echo "   💡 計算過程あり"
            fi
            ;;
          R3)
            if [[ "$RESP_CLEAN" =~ (火.*水.*木|3日) ]]; then
              ((EXPLANATION_QUALITY++))
              echo "   💡 順序説明あり"
            fi
            ;;
          R4)
            if [[ "$RESP_CLEAN" =~ (10.*2|2.*10) ]]; then
              ((EXPLANATION_QUALITY++))
              echo "   💡 計算説明あり"
            fi
            ;;
        esac
      else
        echo "❌ 不正解: $RESP_SHORT... (${Q_TIME}秒)"
      fi
    done
    
    MODEL_END=$(date +%s)
    MODEL_TIME=$((MODEL_END - MODEL_START))
    
    PERCENTAGE=$(echo "scale=0; $SCORE * 100 / ${#REASONING_TASKS[@]}" | bc)
    
    echo ""
    echo "📊 結果:"
    echo "正解数: $SCORE/${#REASONING_TASKS[@]} (${PERCENTAGE}%)"
    echo "説明品質: ${EXPLANATION_QUALITY}/4"
    echo "実行時間: ${MODEL_TIME}秒"
    echo ""
    
    MODEL_SCORES[$MODEL]="$SCORE/${#REASONING_TASKS[@]} (${PERCENTAGE}%)"
    REASONING_QUALITY[$MODEL]="${EXPLANATION_QUALITY}/4"
  done
  
  END_TIME=$(date +%s)
  TOTAL_TIME=$((END_TIME - START_TIME))
  
  echo "╔════════════════════════════════════════╗"
  echo "║        推論チェーンテスト結果          ║"
  echo "╚════════════════════════════════════════╝"
  echo ""
  
  echo "📊 モデル別スコア:"
  for MODEL in "${!MODEL_SCORES[@]}"; do
    printf "%-15s : %-15s (説明品質: %s)\n" "$MODEL" "${MODEL_SCORES[$MODEL]}" "${REASONING_QUALITY[$MODEL]}"
  done
  
  echo ""
  echo "⏱️ 総実行時間: ${TOTAL_TIME}秒"
  echo ""
  
  # 総合評価
  echo "🏆 推論能力評価:"
  for MODEL in "${!MODEL_SCORES[@]}"; do
    SCORE=$(echo "${MODEL_SCORES[$MODEL]}" | cut -d'/' -f1)
    QUALITY=$(echo "${REASONING_QUALITY[$MODEL]}" | cut -d'/' -f1)
    TOTAL=$((SCORE + QUALITY))
    
    case $TOTAL in
      8) echo "⭐⭐⭐ $MODEL - 完璧な推論能力" ;;
      6|7) echo "⭐⭐ $MODEL - 優れた推論能力" ;;
      4|5) echo "⭐ $MODEL - 基本的な推論能力" ;;
      *) echo "📌 $MODEL - 推論能力に課題" ;;
    esac
  done
  
  echo ""
  echo "終了時刻: $(date)"
} | tee "$OUTPUT_FILE"

echo ""
echo "📄 結果保存: $OUTPUT_FILE"