#\!/usr/bin/env bash
set -euo pipefail

MODELS=(
  "llava:7b"
  "gemma3:1b" 
  "qwen3:latest"
  "gemma3:4b"
  "jaahas/qwen3-abliterated:0.6b"
)

PROMPTS=(
  "日本語で短い自己紹介をしてください。"
  "富士山の標高は？"
  "『走れメロス』を一文で要約してください。"
)

for MODEL in "${MODELS[@]}"; do
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "MODEL: $MODEL"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  for ((i=0; i<${#PROMPTS[@]}; i++)); do
    Q="${PROMPTS[$i]}"
    echo -e "\n質問$((i+1)): $Q"
    
    RESP=$(curl -s http://localhost:11434/api/generate \
      -H "Content-Type: application/json" \
      -d '{"model":"'"$MODEL"'","prompt":"'"${Q//"/\\"}"'","stream":false,"num_predict":128}')
    
    ANSWER=$(echo "$RESP" | jq -r '.response // "ERROR"')
    echo "回答: $ANSWER"
  done
  echo -e "\n"
done
