#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="quick_thinking_comparison_${TIMESTAMP}.txt"

# 開始時刻
START_TIME=$(date +%s)

# 主要モデルを比較
MODELS=(
  "gemma3:4b"
  "phi3:mini"
  "llama3.2:1b"
  "qwen3:latest"
)

# 思考を促す質問（1つ）
QUESTION="箱の中に赤いボールが3個、青いボールが2個入っています。目を閉じて2個取り出したところ、両方とも赤でした。残りのボールから1個取り出すとき、それが青い確率は？段階的に考えて答えてください。"

{
  echo "🧠 思考プロセス比較テスト"
  echo "開始時刻: $(date)"
  echo "========================"
  echo ""
  echo "【問題】"
  echo "$QUESTION"
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  for MODEL in "${MODELS[@]}"; do
    echo ""
    echo "📦 MODEL: $MODEL"
    echo "---"
    
    Q_START=$(date +%s)
    
    # 各モデルの回答を取得
    RESP=$(curl -s --max-time 25 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"$QUESTION\",\"stream\":false,\"options\":{\"temperature\":0.2,\"num_predict\":200}}" \
      2>/dev/null | jq -r '.response // "TIMEOUT"' 2>/dev/null || echo "ERROR")
    
    Q_END=$(date +%s)
    Q_TIME=$((Q_END - Q_START))
    
    echo "【実際の回答】"
    echo "$RESP" | fold -w 70 -s
    echo ""
    echo "⏱️ 応答時間: ${Q_TIME}秒"
    
    # 正解判定
    if [[ "$RESP" =~ (2/3|66|67|0\.66|0\.67|２／３) ]]; then
      echo "✅ 正解（2/3）"
    else
      echo "❌ 不正解"
    fi
    
    # 思考プロセスの質を評価
    PROCESS_SCORE=0
    if [[ "$RESP" =~ (残り|remaining|1.*赤|1.*red) ]]; then
      ((PROCESS_SCORE++))
      echo "💡 残りのボールを正しく把握"
    fi
    if [[ "$RESP" =~ (2.*青|2.*blue|青.*2) ]]; then
      ((PROCESS_SCORE++))
      echo "💡 青ボールの数を正しく認識"
    fi
    if [[ "$RESP" =~ (3個|3.*ボール|total.*3) ]]; then
      ((PROCESS_SCORE++))
      echo "💡 残り総数を正しく計算"
    fi
    
    echo "思考プロセス評価: ${PROCESS_SCORE}/3"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  done
  
  END_TIME=$(date +%s)
  TOTAL_TIME=$((END_TIME - START_TIME))
  
  echo ""
  echo "⏱️ 総実行時間: ${TOTAL_TIME}秒"
  echo "終了時刻: $(date)"
} | tee "$OUTPUT_FILE"

echo ""
echo "📄 結果保存: $OUTPUT_FILE"