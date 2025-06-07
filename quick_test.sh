#!/usr/bin/env bash
set -euo pipefail

# 3モデルのみでクイックテスト
MODELS=(
  "gemma3:1b" 
  "llava:7b"
  "qwen3:latest"
)

PROMPTS=(
  "富士山の標高は？"
  "『走れメロス』を一文で要約してください。"
)

echo "╔════════════════════════════════════════════════════════════════════╗"
echo "║               日本語モデル クイックテスト結果                      ║"
echo "╚════════════════════════════════════════════════════════════════════╝"

for MODEL in "${MODELS[@]}"; do
  echo -e "\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "📊 MODEL: $MODEL"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  for ((i=0; i<${#PROMPTS[@]}; i++)); do
    Q="${PROMPTS[$i]}"
    echo -e "\n▶ 質問: $Q"
    
    # API call with timeout
    RESP=$(timeout 30s curl -s http://localhost:11434/api/generate \
      -H "Content-Type: application/json" \
      -d '{"model":"'"$MODEL"'","prompt":"'"${Q//"/\\"}"'","stream":false,"options":{"num_predict":100}}' || echo '{"response":"タイムアウト","eval_count":0,"eval_duration":0}')
    
    # Extract data
    ANSWER=$(echo "$RESP" | jq -r '.response // "ERROR"' | head -5)
    TOKENS=$(echo "$RESP" | jq -r '.eval_count // 0')
    EVAL_DURATION=$(echo "$RESP" | jq -r '.eval_duration // 0')
    
    # Calculate metrics
    if [ "$EVAL_DURATION" -gt 0 ]; then
      EVAL_SEC=$(echo "scale=2; $EVAL_DURATION/1000000000" | bc)
      TPS=$(echo "scale=1; $TOKENS/$EVAL_SEC" | bc 2>/dev/null || echo "0")
    else
      EVAL_SEC="0"
      TPS="0"
    fi
    
    # Display answer
    echo "📝 回答:"
    echo "$ANSWER" | sed 's/^/   /'
    
    # Display metrics
    echo -e "\n📈 性能: ${TOKENS}トークン / ${EVAL_SEC}秒 / ${TPS} tok/s"
  done
done

echo -e "\n╚════════════════════════════════════════════════════════════════════╝"