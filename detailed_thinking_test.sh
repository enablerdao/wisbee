#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="detailed_thinking_results_${TIMESTAMP}.txt"

# 開始時刻
START_TIME=$(date +%s)

# 全モデルをテスト
MODELS=(
  "gemma3:4b"
  "qwen3:latest"
  "phi3:mini"
  "llama3.2:1b"
  "llava:7b"
  "gemma3:1b"
)

# 思考を要する複雑な質問
declare -A THINKING_QUESTIONS=(
  ["T1"]="3人の友人がレストランで食事をしました。請求書は30ドルでした。各自が10ドルずつ支払いましたが、店員が5ドル割引してくれたので、25ドルで済みました。店員は3ドルを返金し、残り2ドルをチップとして受け取りました。各自は9ドル支払ったことになり（10ドル-1ドル返金）、合計27ドル。チップの2ドルを足すと29ドル。あれ？1ドルはどこに消えた？"
  
  ["T2"]="箱の中に赤いボールが3個、青いボールが2個入っています。目を閉じて2個取り出したところ、両方とも赤でした。残りのボールから1個取り出すとき、それが青い確率は？"
  
  ["T3"]="「私は嘘つきです」と言っている人がいます。この発言は真実でしょうか、嘘でしょうか？理由も説明してください。"
)

{
  echo "🧠 詳細思考テスト - 実際の回答を記録"
  echo "開始時刻: $(date)"
  echo "======================================"
  echo ""
  
  for MODEL in "${MODELS[@]}"; do
    echo "╔══════════════════════════════════════╗"
    echo "║ MODEL: $MODEL"
    echo "╚══════════════════════════════════════╝"
    echo ""
    
    MODEL_START=$(date +%s)
    
    # T1: レストランのパラドックス
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎯 問題1: レストランの1ドル問題"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "${THINKING_QUESTIONS[T1]}"
    echo ""
    
    T1_START=$(date +%s)
    T1_PROMPT="以下の問題について、ステップバイステップで考えて答えてください：\n\n${THINKING_QUESTIONS[T1]}"
    
    echo "【$MODEL の回答】"
    T1_RESP=$(curl -s --max-time 30 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"$T1_PROMPT\",\"stream\":false,\"options\":{\"temperature\":0.3,\"num_predict\":300}}" \
      2>/dev/null | jq -r '.response // "TIMEOUT"' 2>/dev/null || echo "ERROR")
    
    T1_END=$(date +%s)
    T1_TIME=$((T1_END - T1_START))
    
    # 実際の回答を表示
    echo "$T1_RESP" | fold -w 80 -s
    echo ""
    echo "⏱️ 応答時間: ${T1_TIME}秒"
    echo ""
    
    # T2: 確率問題
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🎲 問題2: 条件付き確率"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "${THINKING_QUESTIONS[T2]}"
    echo ""
    
    T2_START=$(date +%s)
    T2_PROMPT="次の確率問題を段階的に解いてください：\n\n${THINKING_QUESTIONS[T2]}"
    
    echo "【$MODEL の回答】"
    T2_RESP=$(curl -s --max-time 30 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"$T2_PROMPT\",\"stream\":false,\"options\":{\"temperature\":0.2,\"num_predict\":250}}" \
      2>/dev/null | jq -r '.response // "TIMEOUT"' 2>/dev/null || echo "ERROR")
    
    T2_END=$(date +%s)
    T2_TIME=$((T2_END - T2_START))
    
    echo "$T2_RESP" | fold -w 80 -s
    echo ""
    echo "⏱️ 応答時間: ${T2_TIME}秒"
    echo ""
    
    # T3: パラドックス
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🤔 問題3: 嘘つきのパラドックス"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "${THINKING_QUESTIONS[T3]}"
    echo ""
    
    T3_START=$(date +%s)
    T3_PROMPT="${THINKING_QUESTIONS[T3]}"
    
    echo "【$MODEL の回答】"
    T3_RESP=$(curl -s --max-time 30 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"$T3_PROMPT\",\"stream\":false,\"options\":{\"temperature\":0.3,\"num_predict\":200}}" \
      2>/dev/null | jq -r '.response // "TIMEOUT"' 2>/dev/null || echo "ERROR")
    
    T3_END=$(date +%s)
    T3_TIME=$((T3_END - T3_START))
    
    echo "$T3_RESP" | fold -w 80 -s
    echo ""
    echo "⏱️ 応答時間: ${T3_TIME}秒"
    echo ""
    
    MODEL_END=$(date +%s)
    MODEL_TIME=$((MODEL_END - MODEL_START))
    
    echo "📊 ${MODEL} の総合時間: ${MODEL_TIME}秒"
    echo ""
    echo "═══════════════════════════════════════"
    echo ""
  done
  
  END_TIME=$(date +%s)
  TOTAL_TIME=$((END_TIME - START_TIME))
  
  echo "⏱️ 全体の実行時間: ${TOTAL_TIME}秒"
  echo "終了時刻: $(date)"
} | tee "$OUTPUT_FILE"

echo ""
echo "📄 詳細な回答は以下に保存されました:"
echo "→ $OUTPUT_FILE"