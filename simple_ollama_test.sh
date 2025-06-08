#!/usr/bin/env bash
# -----------------------------------------------------------------------------
# simple_ollama_test.sh – Quick sanity test for Japanese chat models on Ollama
# -----------------------------------------------------------------------------
# 目的:
#   * "手元でモデルがまともに日本語応答できるか" を 3 問でサクッと確認
#   * トークン数 / 推論時間 / tok/s を簡易表示
#   * 依存は curl / jq / bc のみ (brew install jq bc)
#
# 使い方:
#   ./simple_ollama_test.sh                 # 既定 2 モデルでテスト
#   ./simple_ollama_test.sh gemma3:4b llava:7b  # 任意モデルを列挙
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
printf "%-20s │ %3s │ %5s │ %6s\n" "MODEL" "Q#" "TOK" "TOK/S"
printf -- "────────────────────┼────┼──────┼───────\n"

for MODEL in "${MODELS[@]}"; do
  TOTAL_TOK=0; TOTAL_SEC=0
  for ((i=0; i<${#PROMPTS[@]}; i++)); do
    Q="${PROMPTS[$i]}"
    RESP=$(curl -s http://localhost:11434/api/generate \
      -H "Content-Type: application/json" \
      -d '{"model":"'"$MODEL"'","prompt":"'"${Q//"/\\"}"'","stream":false,"num_predict":128}')

    TOK=$( jq -r '.eval_count'    <<<"$RESP" )
    DUR=$( jq -r '.eval_duration' <<<"$RESP" )
    SEC=$(echo "scale=2; $DUR/1e9" | bc)
    TPS=$(echo "scale=1; $TOK/$SEC" | bc)

    printf "%-20s │ %3d │ %5d │ %6s\n" "$MODEL" "$((i+1))" "$TOK" "$TPS"

    TOTAL_TOK=$((TOTAL_TOK + TOK))
    TOTAL_SEC=$(echo "$TOTAL_SEC + $SEC" | bc)
  done
  AVG_TPS=$(echo "scale=2; $TOTAL_TOK/$TOTAL_SEC" | bc)
  echo "────────────────────┼────┼──────┼───────" 
  printf "%-20s │  -  │  --- │  %6s  ← Avg tok/s (3 問)\n" "$MODEL" "$AVG_TPS"
  echo "============================================================="
  echo
done

# 終了
exit 0