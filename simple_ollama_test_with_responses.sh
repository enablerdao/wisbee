#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# simple_ollama_test_with_responses.sh – Test Japanese chat models and show responses
# -----------------------------------------------------------------------------
set -euo pipefail

# ---------- デフォルトモデル ----------
DEFAULT_MODELS=(
  "gemma3:1b"
  "qwen3:latest"
)

# ---------- テスト用プロンプト 3 問 ----------
PROMPTS=(
  "日本語で短い自己紹介をしてください。"
  "富士山の標高は？"
  "『走れメロス』を一文で要約してください。"
)

# ---------- CLI 引数 ----------
if [[ $# -eq 0 ]]; then
  MODELS=("${DEFAULT_MODELS[@]}")
else
  MODELS=("$@")
fi

# ---------- 依存チェック ----------
for CMD in curl jq bc; do
  command -v $CMD >/dev/null 2>&1 || {
    echo "❌ $CMD が見つかりません。brew install $CMD" >&2; exit 1; }
done

# ---------- 実行 ----------
for MODEL in "${MODELS[@]}"; do
  echo "============================================================="
  echo "🤖 MODEL: $MODEL"
  echo "============================================================="
  
  TOTAL_TOK=0; TOTAL_SEC=0
  
  for ((i=0; i<${#PROMPTS[@]}; i++)); do
    Q="${PROMPTS[$i]}"
    echo
    echo "📝 Question $((i+1)): $Q"
    echo "-------------------------------------------------------------"
    
    RESP=$(curl -s http://localhost:11434/api/generate \
      -H "Content-Type: application/json" \
      -d '{"model":"'"$MODEL"'","prompt":"'"${Q//"/\\"}"'","stream":false,"num_predict":128}')
    
    # Extract response and metrics
    RESPONSE_TEXT=$(jq -r '.response' <<<"$RESP")
    TOK=$( jq -r '.eval_count'    <<<"$RESP" )
    DUR=$( jq -r '.eval_duration' <<<"$RESP" )
    SEC=$(echo "scale=2; $DUR/1e9" | bc)
    TPS=$(echo "scale=1; $TOK/$SEC" | bc)
    
    echo "💬 Response:"
    echo "$RESPONSE_TEXT"
    echo
    echo "📊 Metrics: $TOK tokens | ${SEC}s | ${TPS} tok/s"
    
    TOTAL_TOK=$((TOTAL_TOK + TOK))
    TOTAL_SEC=$(echo "$TOTAL_SEC + $SEC" | bc)
  done
  
  AVG_TPS=$(echo "scale=2; $TOTAL_TOK/$TOTAL_SEC" | bc)
  echo
  echo "📈 Average performance: $AVG_TPS tok/s (3 questions)"
  echo
done

# 終了
exit 0