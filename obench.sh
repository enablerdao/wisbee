#!/usr/bin/env zsh
# obench.sh  –  Ollama model benchmark helper (macOS / zsh)
# ----------------------------------------------------------
# 使い方:
#   ./obench.sh                   # 既定5モデルをベンチ
#   ./obench.sh gemma2:2b llama3  # モデルを列挙してベンチ
#   ./obench.sh -h                # ヘルプ
#
# 依存: curl, jq, bc  (brew install jq bc)

# ---------- ヘルプ ----------
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
  cat <<'EOS'
obench.sh – Ollama ベンチマークスクリプト
USAGE:
  ./obench.sh                    # 既定モデル(5件)を測定
  ./obench.sh <tag1> <tag2> ...  # 任意のモデルタグを測定
OPTIONS:
  -h, --help       このヘルプを表示
EOS
  exit 0
fi

# ---------- 依存チェック ----------
for cmd in curl jq bc; do
  command -v $cmd >/dev/null 2>&1 || {
    echo "❌ $cmd が見つかりません。brew install $cmd"; exit 1; }
done

# ---------- モデルリスト ----------
if [[ $# -eq 0 ]]; then
  models=(
    "llava:7b"
    "qwen3:latest"
    "gemma3:4b"
    "gemma3:1b"
    "jaahas/qwen3-abliterated:0.6b"
  )
else
  models=("$@")
fi

# ---------- 表ヘッダ ----------
printf "%-32s │ %7s │ %7s │ %7s\n" "MODEL" "TOK" "SEC" "TOK/S"
printf -- "────────────────────────────────┼────────┼────────┼────────\n"

# ---------- 各モデルを計測 ----------
for m in "${models[@]}"; do
  resp=$(curl -s http://localhost:11434/api/generate \
    -H "Content-Type: application/json" \
    -d "{\"model\":\"$m\",\"prompt\":\"benchmark\",\"stream\":false}")

  tok=$( jq -r '.eval_count'    <<<"$resp" )
  dur=$( jq -r '.eval_duration' <<<"$resp" )
  sec=$(echo "scale=3; $dur / 1000000000" | bc)     # ns → s
  tps=$(echo "scale=2; $tok / $sec"        | bc)

  printf "%-32s │ %7d │ %7.2f │ %7.2f\n" "$m" "$tok" "$sec" "$tps"
done
