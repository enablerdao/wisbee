#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="conversation_simple_results_${TIMESTAMP}.txt"

# 開始時刻
START_TIME=$(date +%s)

# 全モデルをテスト
MODELS=(
  "gemma3:4b"
  "qwen3:latest"
  "llava:7b"
  "jaahas/qwen3-abliterated:0.6b"
)

{
  echo "🗣️ 会話継続性テスト（簡略版）"
  echo "開始時刻: $(date)"
  echo "================================"
  
  # 結果集計用
  declare -A MODEL_SCORES
  declare -A RESPONSE_TIMES
  
  for MODEL in "${MODELS[@]}"; do
    echo -e "\n📦 MODEL: $MODEL"
    echo "---"
    
    MODEL_START=$(date +%s)
    SCORE=0
    TOTAL_RESP_TIME=0
    
    # テスト1: 料理の会話（3ターン）
    echo -e "\n🍛 料理の会話テスト"
    
    # ターン1
    echo "Q1: カレーの作り方を教えて"
    T1_START=$(date +%s)
    R1=$(curl -s --max-time 20 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"カレーの作り方を簡潔に教えてください。\",\"stream\":false,\"options\":{\"temperature\":0.2,\"num_predict\":50}}" \
      2>/dev/null | jq -r '.response // "ERROR"' 2>/dev/null || echo "TIMEOUT")
    T1_END=$(date +%s)
    T1_TIME=$((T1_END - T1_START))
    TOTAL_RESP_TIME=$((TOTAL_RESP_TIME + T1_TIME))
    
    R1_SHORT=$(echo "$R1" | tr '\n' ' ' | cut -c1-40)
    echo "A1: $R1_SHORT... (${T1_TIME}秒)"
    [[ "$R1" =~ (カレー|材料|作り方) ]] && ((SCORE++))
    
    # ターン2（前の文脈を参照）
    echo -e "\nQ2: 必要な材料は？"
    T2_START=$(date +%s)
    CONTEXT="カレーの作り方について話しています。必要な材料を教えてください。"
    R2=$(curl -s --max-time 20 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"$CONTEXT\",\"stream\":false,\"options\":{\"temperature\":0.2,\"num_predict\":50}}" \
      2>/dev/null | jq -r '.response // "ERROR"' 2>/dev/null || echo "TIMEOUT")
    T2_END=$(date +%s)
    T2_TIME=$((T2_END - T2_START))
    TOTAL_RESP_TIME=$((TOTAL_RESP_TIME + T2_TIME))
    
    R2_SHORT=$(echo "$R2" | tr '\n' ' ' | cut -c1-40)
    echo "A2: $R2_SHORT... (${T2_TIME}秒)"
    [[ "$R2" =~ (肉|野菜|ルー|じゃがいも|にんじん|玉ねぎ) ]] && ((SCORE++))
    
    # ターン3（前の文脈を参照）
    echo -e "\nQ3: 隠し味のおすすめは？"
    T3_START=$(date +%s)
    CONTEXT="カレーの隠し味のおすすめを教えてください。"
    R3=$(curl -s --max-time 20 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"$CONTEXT\",\"stream\":false,\"options\":{\"temperature\":0.2,\"num_predict\":50}}" \
      2>/dev/null | jq -r '.response // "ERROR"' 2>/dev/null || echo "TIMEOUT")
    T3_END=$(date +%s)
    T3_TIME=$((T3_END - T3_START))
    TOTAL_RESP_TIME=$((TOTAL_RESP_TIME + T3_TIME))
    
    R3_SHORT=$(echo "$R3" | tr '\n' ' ' | cut -c1-40)
    echo "A3: $R3_SHORT... (${T3_TIME}秒)"
    [[ "$R3" =~ (チョコ|コーヒー|はちみつ|りんご|ヨーグルト|隠し味) ]] && ((SCORE++))
    
    # テスト2: プログラミングの会話（2ターン）
    echo -e "\n💻 プログラミングの会話テスト"
    
    # ターン1
    echo "Q1: Pythonで Hello World を出力するには？"
    T4_START=$(date +%s)
    R4=$(curl -s --max-time 20 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"Pythonで Hello World を出力する方法を教えてください。\",\"stream\":false,\"options\":{\"temperature\":0.1,\"num_predict\":30}}" \
      2>/dev/null | jq -r '.response // "ERROR"' 2>/dev/null || echo "TIMEOUT")
    T4_END=$(date +%s)
    T4_TIME=$((T4_END - T4_START))
    TOTAL_RESP_TIME=$((TOTAL_RESP_TIME + T4_TIME))
    
    R4_SHORT=$(echo "$R4" | tr '\n' ' ' | cut -c1-40)
    echo "A1: $R4_SHORT... (${T4_TIME}秒)"
    [[ "$R4" =~ (print|Hello|World) ]] && ((SCORE++))
    
    # ターン2（前の文脈を参照）
    echo -e "\nQ2: 変数に入れてから出力するには？"
    T5_START=$(date +%s)
    CONTEXT="Pythonで変数にHello Worldを入れてから出力する方法を教えてください。"
    R5=$(curl -s --max-time 20 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"$CONTEXT\",\"stream\":false,\"options\":{\"temperature\":0.1,\"num_predict\":40}}" \
      2>/dev/null | jq -r '.response // "ERROR"' 2>/dev/null || echo "TIMEOUT")
    T5_END=$(date +%s)
    T5_TIME=$((T5_END - T5_START))
    TOTAL_RESP_TIME=$((TOTAL_RESP_TIME + T5_TIME))
    
    R5_SHORT=$(echo "$R5" | tr '\n' ' ' | cut -c1-40)
    echo "A2: $R5_SHORT... (${T5_TIME}秒)"
    [[ "$R5" =~ (変数|=|print) ]] && ((SCORE++))
    
    MODEL_END=$(date +%s)
    MODEL_TIME=$((MODEL_END - MODEL_START))
    AVG_RESP_TIME=$((TOTAL_RESP_TIME / 5))
    
    PERCENTAGE=$(echo "scale=0; $SCORE * 100 / 5" | bc)
    
    echo -e "\n📊 モデル評価:"
    echo "スコア: $SCORE/5 (${PERCENTAGE}%)"
    echo "合計時間: ${MODEL_TIME}秒 (平均応答: ${AVG_RESP_TIME}秒)"
    
    MODEL_SCORES[$MODEL]="$SCORE/5 (${PERCENTAGE}%)"
    RESPONSE_TIMES[$MODEL]="${AVG_RESP_TIME}秒"
  done
  
  END_TIME=$(date +%s)
  TOTAL_TIME=$((END_TIME - START_TIME))
  
  echo -e "\n╔════════════════════════════════════════╗"
  echo "║      会話継続性テスト結果              ║"
  echo "╚════════════════════════════════════════╝"
  
  echo -e "\n📊 モデル別スコア:"
  for MODEL in "${!MODEL_SCORES[@]}"; do
    printf "%-25s : %s\n" "$MODEL" "${MODEL_SCORES[$MODEL]}"
  done
  
  echo -e "\n⏱️ 平均応答時間:"
  for MODEL in "${!RESPONSE_TIMES[@]}"; do
    printf "%-25s : %s\n" "$MODEL" "${RESPONSE_TIMES[$MODEL]}"
  done
  
  echo -e "\n⏱️ 総実行時間: ${TOTAL_TIME}秒"
  
  echo -e "\n🏆 評価基準:"
  echo "• 5/5: 優秀な会話理解力"
  echo "• 3-4/5: 基本的な文脈理解"
  echo "• 0-2/5: 文脈理解に課題あり"
  
  echo -e "\n終了時刻: $(date)"
} | tee "$OUTPUT_FILE"

echo -e "\n📄 結果保存: $OUTPUT_FILE"