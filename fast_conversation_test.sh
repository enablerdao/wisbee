#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="fast_conversation_results_${TIMESTAMP}.txt"

# 開始時刻
START_TIME=$(date +%s)

# 高速なモデルを選択
MODELS=(
  "llama3.2:1b"
  "gemma3:1b"
  "phi3:mini"
)

{
  echo "🗣️ 高速会話継続性テスト"
  echo "開始時刻: $(date)"
  echo "========================"
  
  for MODEL in "${MODELS[@]}"; do
    echo -e "\n📦 MODEL: $MODEL"
    echo "---"
    
    MODEL_START=$(date +%s)
    SCORE=0
    
    # シンプルな3ターン会話
    echo -e "\n🍛 料理の会話（3ターン）"
    
    # ターン1: 初期質問
    echo "T1: カレーの材料は？"
    R1=$(curl -s --max-time 10 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"カレーの材料を3つ教えて\",\"stream\":false,\"options\":{\"temperature\":0.1,\"num_predict\":30}}" \
      2>/dev/null | jq -r '.response // "ERROR"' | tr '\n' ' ' | cut -c1-50)
    echo "→ $R1"
    [[ "$R1" =~ (肉|野菜|じゃがいも|にんじん|玉ねぎ) ]] && ((SCORE++))
    
    # ターン2: フォローアップ
    echo -e "\nT2: 肉は何がいい？"
    R2=$(curl -s --max-time 10 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"カレーに使う肉は何がおすすめ？\",\"stream\":false,\"options\":{\"temperature\":0.1,\"num_predict\":30}}" \
      2>/dev/null | jq -r '.response // "ERROR"' | tr '\n' ' ' | cut -c1-50)
    echo "→ $R2"
    [[ "$R2" =~ (牛|豚|鶏|ビーフ|ポーク|チキン) ]] && ((SCORE++))
    
    # ターン3: 関連質問
    echo -e "\nT3: 隠し味は？"
    R3=$(curl -s --max-time 10 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"カレーの隠し味を1つ教えて\",\"stream\":false,\"options\":{\"temperature\":0.1,\"num_predict\":20}}" \
      2>/dev/null | jq -r '.response // "ERROR"' | tr '\n' ' ' | cut -c1-50)
    echo "→ $R3"
    [[ "$R3" =~ (チョコ|コーヒー|はちみつ|りんご|ヨーグルト) ]] && ((SCORE++))
    
    # プログラミング会話（2ターン）
    echo -e "\n💻 コードの会話（2ターン）"
    
    # ターン1
    echo "T1: print文の使い方は？"
    R4=$(curl -s --max-time 10 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"Pythonのprint文の使い方\",\"stream\":false,\"options\":{\"temperature\":0.1,\"num_predict\":30}}" \
      2>/dev/null | jq -r '.response // "ERROR"' | tr '\n' ' ' | cut -c1-50)
    echo "→ $R4"
    [[ "$R4" =~ (print|出力) ]] && ((SCORE++))
    
    # ターン2
    echo -e "\nT2: 変数を使うには？"
    R5=$(curl -s --max-time 10 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"Pythonで変数を使う方法\",\"stream\":false,\"options\":{\"temperature\":0.1,\"num_predict\":30}}" \
      2>/dev/null | jq -r '.response // "ERROR"' | tr '\n' ' ' | cut -c1-50)
    echo "→ $R5"
    [[ "$R5" =~ (=|変数|代入) ]] && ((SCORE++))
    
    MODEL_END=$(date +%s)
    MODEL_TIME=$((MODEL_END - MODEL_START))
    
    PERCENTAGE=$(echo "scale=0; $SCORE * 100 / 5" | bc)
    echo -e "\n📊 スコア: $SCORE/5 (${PERCENTAGE}%) - ${MODEL_TIME}秒"
  done
  
  END_TIME=$(date +%s)
  TOTAL_TIME=$((END_TIME - START_TIME))
  
  echo -e "\n⏱️ 総実行時間: ${TOTAL_TIME}秒"
  echo "終了時刻: $(date)"
} | tee "$OUTPUT_FILE"

echo -e "\n📄 → $OUTPUT_FILE"