#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="coding_test_results_${TIMESTAMP}.txt"

# 開始時刻
START_TIME=$(date +%s)

# 全モデルをテスト
MODELS=(
  "gemma3:4b"
  "qwen3:latest"
  "llama3.2:1b"
  "phi3:mini"
)

# コーディング課題
declare -A CODING_TASKS=(
  ["C1"]="配列[3,1,4,1,5,9]を逆順にするPythonコードを書いて"
  ["C2"]="1から10までの合計を計算するPythonコードを書いて"
  ["C3"]="文字列 'hello' を大文字にするPythonコードを書いて"
  ["C4"]="リスト内の最大値を見つけるPythonコードを書いて"
)

# 期待されるキーワード
declare -A CODE_EXPECTED=(
  ["C1"]="reverse|[::-1]|reversed"
  ["C2"]="sum|range|for.*in"
  ["C3"]="upper|HELLO"
  ["C4"]="max|maximum"
)

{
  echo "💻 コーディング能力テスト"
  echo "開始時刻: $(date)"
  echo "================================"
  echo ""
  
  # 結果集計用
  declare -A MODEL_SCORES
  declare -A CODE_QUALITY
  
  for MODEL in "${MODELS[@]}"; do
    echo "📦 MODEL: $MODEL"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    MODEL_START=$(date +%s)
    SCORE=0
    QUALITY_POINTS=0
    
    for KEY in "${!CODING_TASKS[@]}"; do
      TASK="${CODING_TASKS[$KEY]}"
      echo ""
      echo "📝 $KEY: $TASK"
      
      Q_START=$(date +%s)
      
      # API呼び出し
      RESP=$(curl -s --max-time 20 http://localhost:11434/api/generate \
        -d "{\"model\":\"$MODEL\",\"prompt\":\"$TASK\",\"stream\":false,\"options\":{\"temperature\":0.1,\"num_predict\":100}}" \
        2>/dev/null | jq -r '.response // "TIMEOUT"' 2>/dev/null || echo "ERROR")
      
      Q_END=$(date +%s)
      Q_TIME=$((Q_END - Q_START))
      
      # <think>タグを除去
      RESP_CLEAN=$(echo "$RESP" | sed 's/<think>.*<\/think>//g' | sed 's/<think>.*//g')
      RESP_SHORT=$(echo "$RESP_CLEAN" | tr '\n' ' ' | cut -c1-80)
      
      # 基本評価
      if [[ "$RESP_CLEAN" =~ ${CODE_EXPECTED[$KEY]} ]]; then
        echo "✅ 正解: $RESP_SHORT... (${Q_TIME}秒)"
        ((SCORE++))
        
        # コード品質評価
        if [[ "$RESP_CLEAN" =~ (```python|```py) ]]; then
          ((QUALITY_POINTS++))
          echo "   📌 コードブロック形式: ✓"
        fi
        
        if [[ "$RESP_CLEAN" =~ (print|result|output) ]]; then
          ((QUALITY_POINTS++))
          echo "   📌 出力処理: ✓"
        fi
      else
        echo "❌ 不正解: $RESP_SHORT... (${Q_TIME}秒)"
      fi
    done
    
    MODEL_END=$(date +%s)
    MODEL_TIME=$((MODEL_END - MODEL_START))
    
    PERCENTAGE=$(echo "scale=0; $SCORE * 100 / ${#CODING_TASKS[@]}" | bc)
    
    echo ""
    echo "📊 結果:"
    echo "スコア: $SCORE/${#CODING_TASKS[@]} (${PERCENTAGE}%)"
    echo "コード品質ポイント: ${QUALITY_POINTS}"
    echo "実行時間: ${MODEL_TIME}秒"
    echo ""
    
    MODEL_SCORES[$MODEL]="$SCORE/${#CODING_TASKS[@]} (${PERCENTAGE}%)"
    CODE_QUALITY[$MODEL]="${QUALITY_POINTS}pts"
  done
  
  END_TIME=$(date +%s)
  TOTAL_TIME=$((END_TIME - START_TIME))
  
  echo "╔════════════════════════════════════════╗"
  echo "║       コーディングテスト結果           ║"
  echo "╚════════════════════════════════════════╝"
  echo ""
  
  echo "📊 モデル別スコア:"
  for MODEL in "${!MODEL_SCORES[@]}"; do
    printf "%-20s : %s (品質: %s)\n" "$MODEL" "${MODEL_SCORES[$MODEL]}" "${CODE_QUALITY[$MODEL]}"
  done
  
  echo ""
  echo "⏱️ 総実行時間: ${TOTAL_TIME}秒"
  echo ""
  echo "📝 評価基準:"
  echo "• 正解: 期待されるメソッド/関数の使用"
  echo "• 品質: コードブロック形式、出力処理の有無"
  echo ""
  echo "終了時刻: $(date)"
} | tee "$OUTPUT_FILE"

echo ""
echo "📄 結果保存完了: $OUTPUT_FILE"