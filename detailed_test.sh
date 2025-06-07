#!/usr/bin/env bash
set -euo pipefail

# Color codes
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
RED='\033[0;31m'
NC='\033[0m' # No Color

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

echo -e "${CYAN}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                    Ollama 日本語モデル詳細テスト結果                       ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════╝${NC}"

for MODEL in "${MODELS[@]}"; do
  echo -e "\n${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  echo -e "${YELLOW}📊 MODEL: ${MODEL}${NC}"
  echo -e "${YELLOW}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
  
  TOTAL_TOKENS=0
  TOTAL_TIME=0
  
  for ((i=0; i<${#PROMPTS[@]}; i++)); do
    Q="${PROMPTS[$i]}"
    echo -e "\n${GREEN}▶ 質問$((i+1)): ${Q}${NC}"
    
    # API call
    RESP=$(curl -s http://localhost:11434/api/generate \
      -H "Content-Type: application/json" \
      -d '{"model":"'"$MODEL"'","prompt":"'"${Q//"/\\"}"'","stream":false,"options":{"num_predict":200}}')
    
    # Extract data
    ANSWER=$(echo "$RESP" | jq -r '.response // "ERROR"')
    TOKENS=$(echo "$RESP" | jq -r '.eval_count // 0')
    PROMPT_TOKENS=$(echo "$RESP" | jq -r '.prompt_eval_count // 0')
    TOTAL_DURATION=$(echo "$RESP" | jq -r '.total_duration // 0')
    EVAL_DURATION=$(echo "$RESP" | jq -r '.eval_duration // 0')
    
    # Calculate metrics
    TOTAL_SEC=$(echo "scale=2; $TOTAL_DURATION/1000000000" | bc)
    EVAL_SEC=$(echo "scale=2; $EVAL_DURATION/1000000000" | bc)
    TPS=$(echo "scale=1; $TOKENS/$EVAL_SEC" | bc 2>/dev/null || echo "0")
    
    # Display answer (truncate if too long)
    echo -e "${BLUE}📝 回答:${NC}"
    if [ ${#ANSWER} -gt 300 ]; then
      echo "${ANSWER:0:300}..."
    else
      echo "$ANSWER"
    fi
    
    # Display metrics
    echo -e "\n${CYAN}📈 パフォーマンス:${NC}"
    echo "   ├─ 生成トークン数: $TOKENS"
    echo "   ├─ プロンプトトークン数: $PROMPT_TOKENS"
    echo "   ├─ 生成時間: ${EVAL_SEC}秒"
    echo "   ├─ 合計時間: ${TOTAL_SEC}秒"
    echo "   └─ 速度: ${TPS} tok/s"
    
    TOTAL_TOKENS=$((TOTAL_TOKENS + TOKENS))
    TOTAL_TIME=$(echo "$TOTAL_TIME + $EVAL_SEC" | bc)
  done
  
  # Summary for model
  AVG_TPS=$(echo "scale=2; $TOTAL_TOKENS/$TOTAL_TIME" | bc 2>/dev/null || echo "0")
  echo -e "\n${RED}📊 ${MODEL} サマリー:${NC}"
  echo "   ├─ 合計生成トークン: $TOTAL_TOKENS"
  echo "   ├─ 合計生成時間: ${TOTAL_TIME}秒"
  echo "   └─ 平均速度: ${AVG_TPS} tok/s"
done

echo -e "\n${CYAN}╔════════════════════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║                              テスト完了                                    ║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════════════════════╝${NC}"