#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="model_test_results_${TIMESTAMP}.txt"

# 開始時刻
START_TIME=$(date +%s)

# 利用可能なモデル
MODELS=(
  "gemma3:4b"
  "qwen3:latest"
  "llava:7b"
  "jaahas/qwen3-abliterated:0.6b"
)

# 各モデル用の質問（3問ずつ）
declare -A QUESTIONS=(
  ["Q1"]="日本の首都はどこですか？"
  ["Q2"]="5 + 7 = ?"
  ["Q3"]="「ありがとう」を英語で言うと？"
)

# 期待される回答
declare -A EXPECTED=(
  ["Q1"]="東京"
  ["Q2"]="12"
  ["Q3"]="Thank you|Thanks"
)

{
  echo "🚀 モデルテスト (1モデル1問40秒制限)"
  echo "開始時刻: $(date)"
  echo "=================================="
  
  # 結果サマリー用
  declare -A MODEL_RESULTS
  declare -A MODEL_DETAILS
  
  # 各モデルをテスト
  for MODEL in "${MODELS[@]}"; do
    echo -e "\n📦 MODEL: $MODEL"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    MODEL_START=$(date +%s)
    SCORE=0
    DETAILS=""
    
    for KEY in "${!QUESTIONS[@]}"; do
      Q="${QUESTIONS[$KEY]}"
      echo -e "\n🔍 $KEY: $Q"
      
      QUESTION_START=$(date +%s)
      
      # curlで実行（タイムアウト40秒）
      RESP=$(curl -s --max-time 40 http://localhost:11434/api/generate \
        -d "{\"model\":\"$MODEL\",\"prompt\":\"$Q 簡潔に答えてください。\",\"stream\":false,\"options\":{\"temperature\":0.1,\"num_predict\":50}}" \
        2>/dev/null | jq -r '.response // "TIMEOUT"' 2>/dev/null || echo "CURL_ERROR")
      
      QUESTION_END=$(date +%s)
      QUESTION_TIME=$((QUESTION_END - QUESTION_START))
      
      # 応答を整形（最初の50文字）
      RESP_SHORT=$(echo "$RESP" | tr '\n' ' ' | sed 's/  */ /g' | cut -c1-50)
      
      # 評価
      if [[ "$RESP" =~ ${EXPECTED[$KEY]} ]]; then
        echo "✅ 正解: $RESP_SHORT (${QUESTION_TIME}秒)"
        ((SCORE++))
        DETAILS+="$KEY:✅(${QUESTION_TIME}s) "
      else
        echo "❌ 不正解: $RESP_SHORT (${QUESTION_TIME}秒)"
        DETAILS+="$KEY:❌(${QUESTION_TIME}s) "
      fi
      
      # 40秒チェック
      if [ $QUESTION_TIME -ge 40 ]; then
        echo "⚠️  タイムアウト (40秒)"
      fi
    done
    
    MODEL_END=$(date +%s)
    MODEL_TIME=$((MODEL_END - MODEL_START))
    
    PERCENTAGE=$(echo "scale=0; $SCORE * 100 / ${#QUESTIONS[@]}" | bc)
    
    echo -e "\n📊 モデル結果:"
    echo "スコア: $SCORE/${#QUESTIONS[@]} (${PERCENTAGE}%)"
    echo "合計時間: ${MODEL_TIME}秒"
    echo "詳細: $DETAILS"
    
    # 結果を保存
    MODEL_RESULTS[$MODEL]="$SCORE/${#QUESTIONS[@]}(${PERCENTAGE}%) ${MODEL_TIME}秒"
    MODEL_DETAILS[$MODEL]="$DETAILS"
  done
  
  END_TIME=$(date +%s)
  TOTAL_TIME=$((END_TIME - START_TIME))
  
  echo -e "\n╔════════════════════════════════════════╗"
  echo "║          テスト結果サマリー            ║"
  echo "╚════════════════════════════════════════╝"
  
  echo -e "\n📊 モデル別スコア:"
  for MODEL in "${!MODEL_RESULTS[@]}"; do
    printf "%-30s : %s\n" "$MODEL" "${MODEL_RESULTS[$MODEL]}"
  done
  
  echo -e "\n📋 詳細結果:"
  for MODEL in "${!MODEL_DETAILS[@]}"; do
    printf "%-30s : %s\n" "$MODEL" "${MODEL_DETAILS[$MODEL]}"
  done
  
  echo -e "\n⏱️  総実行時間: ${TOTAL_TIME}秒"
  echo "平均時間/モデル: $(echo "scale=1; $TOTAL_TIME / ${#MODELS[@]}" | bc)秒"
  
  # 最優秀モデルを判定
  echo -e "\n🏆 パフォーマンス分析:"
  for MODEL in "${!MODEL_RESULTS[@]}"; do
    RESULT="${MODEL_RESULTS[$MODEL]}"
    SCORE=$(echo "$RESULT" | cut -d'/' -f1)
    if [ "$SCORE" = "3" ]; then
      echo "⭐ $MODEL: 全問正解！"
    elif [ "$SCORE" = "2" ]; then
      echo "👍 $MODEL: 良好なパフォーマンス"
    elif [ "$SCORE" = "1" ]; then
      echo "📌 $MODEL: 改善の余地あり"
    else
      echo "⚠️  $MODEL: 要調整"
    fi
  done
  
  echo -e "\n終了時刻: $(date)"
} | tee "$OUTPUT_FILE"

echo -e "\n📄 結果は $OUTPUT_FILE に保存されました"