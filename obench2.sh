#!/usr/bin/env bash
# ---------------------------------------------------------------
# oeval.sh – Ollama multi-Q&A evaluator (bash 版)
# ---------------------------------------------------------------
# 依存:
#   curl, jq, bc, date      ← brew install jq bc
#   （採点したい場合）環境変数 OPENAI_API_KEY にキーを入れる
#
# 使い方例:
#   ./oeval.sh                       # 既定 5 モデルで評価
#   ./oeval.sh gemma3:1b qwen3:latest --max-tok 128
#   ./oeval.sh --no-score            # 採点せず回答だけ取得
#   ./oeval.sh -h                    # ヘルプ
#
# 質問リスト:
#   同ディレクトリの questions.txt を 1 行 1 問で用意してください。
#
# 出力:
#   端末 … MODEL / Q# / TOK / SCORE 表示
#   ファイル … ~/oeval_logs/oeval_YYYYmmdd_HHMMSS.jsonl に詳細保存
# ---------------------------------------------------------------

set -euo pipefail

# ---------- 既定モデル ----------
DEFAULT_MODELS=(
  "llava:7b"
  "qwen3:latest"
  "gemma3:4b"
  "gemma3:1b"
  "jaahas/qwen3-abliterated:0.6b"
)

# ---------- CLI 引数 ----------
SCORE=true
MAX_TOK=256
MODELS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --no-score) SCORE=false ;;
    --max-tok)  MAX_TOK="$2" ; shift ;;
    -h|--help)
      grep '^# ' "$0" | cut -c4-
      exit 0 ;;
    *)  MODELS+=("$1") ;;
  esac
  shift
done

if [[ ${#MODELS[@]} -eq 0 ]]; then
  MODELS=("${DEFAULT_MODELS[@]}")
fi

# ---------- 質問読み込み ----------
QFILE="questions.txt"
if [[ ! -f "$QFILE" ]]; then
  echo "❌ $QFILE が見つかりません" >&2
  exit 1
fi
mapfile -t QUESTIONS < "$QFILE"

# ---------- ログ設定 ----------
LOGDIR="$HOME/oeval_logs"
mkdir -p "$LOGDIR"
LOGFILE="$LOGDIR/oeval_$(date +%Y%m%d_%H%M%S).jsonl"

echo "▶︎ ログ: $LOGFILE"

echo "MODEL                           │  Q# │ TOK │   SCORE"
echo "────────────────────────────────┼────┼────┼────────"

# ---------- 関数: OpenAI 採点 ----------
function grade() {
  local q="$1" a="$2"
  if [[ "$SCORE" == false || -z "${OPENAI_API_KEY:-}" ]]; then
    echo "NA" ; return
  fi
  local gjson
  gjson=$(curl -s https://api.openai.com/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $OPENAI_API_KEY" \
    -d '{
      "model":"gpt-4o-mini",
      "messages":[
        {"role":"system","content":"You are an evaluator. Score the answer (1–5, higher=better) strictly as a single digit."},
        {"role":"user","content":"Question: '"$q"'. Answer: '"$a"'. Score:"}
      ],
      "max_tokens":1
    }' | jq -r '.choices[0].message.content // "NA"')
  echo "$gjson"
}

# ---------- メイン処理 ----------
for model in "${MODELS[@]}"; do
  for i in "${!QUESTIONS[@]}"; do
    q="${QUESTIONS[$i]}"
    
    # Ollama API 呼び出し
    start_time=$(date +%s.%N)
    response=$(curl -s http://localhost:11434/api/generate \
      -d '{
        "model":"'"$model"'",
        "prompt":"'"$q"'",
        "stream":false,
        "options":{"num_predict":'"$MAX_TOK"'}
      }' | jq -r '.response // "ERROR"')
    end_time=$(date +%s.%N)
    
    # トークン数（簡易的に単語数で代用）
    tok=$(echo "$response" | wc -w | tr -d ' ')
    
    # 採点
    score=$(grade "$q" "$response")
    
    # 表示
    printf "%-30s │ %3d │ %3d │ %7s\n" "$model" "$((i+1))" "$tok" "$score"
    
    # ログ保存
    jq -n \
      --arg model "$model" \
      --arg q "$q" \
      --arg a "$response" \
      --arg score "$score" \
      --argjson tok "$tok" \
      --argjson time "$(echo "$end_time - $start_time" | bc)" \
      '{model:$model, question:$q, answer:$a, score:$score, tokens:$tok, time:$time}' \
      >> "$LOGFILE"
  done
done

echo ""
echo "✅ 完了: $LOGFILE"
