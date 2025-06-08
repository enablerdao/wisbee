#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="creative_thinking_results_${TIMESTAMP}.txt"

# 開始時刻
START_TIME=$(date +%s)

# テスト対象モデル
MODELS=(
  "gemma3:4b"
  "phi3:mini"
  "llama3.2:1b"
  "gemma3:1b"
)

# 創造的思考を要する質問
declare -A CREATIVE_TASKS=(
  ["C1"]="もし重力が半分になったら、日常生活はどう変わる？3つ例を挙げて。"
  ["C2"]="新しい色を発明してください。その色の名前と、どんな感じの色か説明して。"
  ["C3"]="水が固体になると体積が増える理由を、小学生にも分かるように説明して。"
)

{
  echo "🎨 創造的思考テスト - 実際の回答記録"
  echo "開始時刻: $(date)"
  echo "===================================="
  
  for MODEL in "${MODELS[@]}"; do
    echo ""
    echo "╔═══════════════════════════════════════╗"
    echo "║ MODEL: $MODEL"
    echo "╚═══════════════════════════════════════╝"
    
    # C1: 重力が半分
    echo ""
    echo "🌍 質問1: 重力が半分になったら？"
    echo "---"
    
    C1_START=$(date +%s)
    C1_RESP=$(curl -s --max-time 20 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"${CREATIVE_TASKS[C1]}\",\"stream\":false,\"options\":{\"temperature\":0.7,\"num_predict\":150}}" \
      2>/dev/null | jq -r '.response // "TIMEOUT"' 2>/dev/null || echo "ERROR")
    C1_END=$(date +%s)
    C1_TIME=$((C1_END - C1_START))
    
    echo "【回答】"
    echo "$C1_RESP" | fold -w 70 -s
    echo ""
    echo "⏱️ ${C1_TIME}秒"
    
    # 創造性評価
    EXAMPLES=$(echo "$C1_RESP" | grep -E "[0-9]\.|\*|・|①|②|③" | wc -l)
    if [ $EXAMPLES -ge 3 ]; then
      echo "✅ 3つの例を提示"
    else
      echo "📌 例の数: $EXAMPLES"
    fi
    
    # C2: 新しい色
    echo ""
    echo "🎨 質問2: 新しい色を発明"
    echo "---"
    
    C2_START=$(date +%s)
    C2_RESP=$(curl -s --max-time 20 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"${CREATIVE_TASKS[C2]}\",\"stream\":false,\"options\":{\"temperature\":0.8,\"num_predict\":100}}" \
      2>/dev/null | jq -r '.response // "TIMEOUT"' 2>/dev/null || echo "ERROR")
    C2_END=$(date +%s)
    C2_TIME=$((C2_END - C2_START))
    
    echo "【回答】"
    echo "$C2_RESP" | fold -w 70 -s
    echo ""
    echo "⏱️ ${C2_TIME}秒"
    
    # 名前があるかチェック
    if [[ "$C2_RESP" =~ (「|」|:|名前) ]]; then
      echo "✅ 色の名前あり"
    else
      echo "❌ 色の名前なし"
    fi
    
    # C3: 水の説明
    echo ""
    echo "💧 質問3: 水が固体になると体積が増える理由"
    echo "---"
    
    C3_START=$(date +%s)
    C3_RESP=$(curl -s --max-time 20 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"${CREATIVE_TASKS[C3]}\",\"stream\":false,\"options\":{\"temperature\":0.3,\"num_predict\":150}}" \
      2>/dev/null | jq -r '.response // "TIMEOUT"' 2>/dev/null || echo "ERROR")
    C3_END=$(date +%s)
    C3_TIME=$((C3_END - C3_START))
    
    echo "【回答】"
    echo "$C3_RESP" | fold -w 70 -s
    echo ""
    echo "⏱️ ${C3_TIME}秒"
    
    # 説明の質を評価
    if [[ "$C3_RESP" =~ (分子|結晶|構造|並び|スペース|隙間) ]]; then
      echo "✅ 科学的説明あり"
    fi
    if [[ "$C3_RESP" =~ (例え|みたい|ように|想像) ]]; then
      echo "✅ 比喩を使用"
    fi
    
    echo ""
    echo "═══════════════════════════════════════"
  done
  
  END_TIME=$(date +%s)
  TOTAL_TIME=$((END_TIME - START_TIME))
  
  echo ""
  echo "⏱️ 総実行時間: ${TOTAL_TIME}秒"
  echo "終了時刻: $(date)"
} | tee "$OUTPUT_FILE"

echo ""
echo "📄 結果保存: $OUTPUT_FILE"