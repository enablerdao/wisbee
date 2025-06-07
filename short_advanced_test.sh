#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="advanced_test_results_${TIMESTAMP}.txt"

# モデルリスト（2つに絞る）
MODELS=(
  "gemma3:4b"
  "qwen3:latest"
)

# 質問サンプル（3問に絞る）
declare -A QUESTIONS=(
  ["Q1"]="地球から月までの平均距離は約何kmですか？"
  ["Q2"]="配列 [5, 2, 9, 1, 5, 6] をPythonで昇順にソートするコードを書いてください。"
  ["Q3"]="日本の47都道府県を五十音順に並べたとき、最初の3つは何ですか？"
)

# 期待される回答のキーワード
declare -A EXPECTED=(
  ["Q1"]="384|38万"
  ["Q2"]="sort|sorted"
  ["Q3"]="愛知.*青森.*秋田"
)

{
  echo "╔═══════════════════════════════════════════════════════════════╗"
  echo "║               高精度日本語モデルテスト                        ║"
  echo "╚═══════════════════════════════════════════════════════════════╝"
  echo ""
  echo "実行日時: $(date)"
  echo ""

  # 結果記録用
  declare -A MODEL_SCORES

  for MODEL in "${MODELS[@]}"; do
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "🤖 MODEL: $MODEL"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    SCORE=0
    
    for KEY in "${!QUESTIONS[@]}"; do
      Q="${QUESTIONS[$KEY]}"
      echo -e "\n📌 $KEY: $Q"
      
      # API呼び出し（タイムアウト短縮）
      RESP=$(curl -s --max-time 30 http://localhost:11434/api/generate \
        -d "{\"model\":\"$MODEL\",\"prompt\":\"$Q\",\"stream\":false,\"options\":{\"temperature\":0.3,\"num_predict\":100}}" \
        | jq -r '.response // "ERROR"')
      
      # 回答表示
      echo "💬 回答:"
      echo "$RESP" | head -5
      
      # 評価
      if [[ "$RESP" =~ ${EXPECTED[$KEY]} ]]; then
        echo "✅ 正答要素を含む"
        ((SCORE++))
      else
        echo "❌ 期待される回答と不一致"
      fi
    done
    
    # モデルスコア計算
    PERCENTAGE=$(echo "scale=1; $SCORE * 100 / ${#QUESTIONS[@]}" | bc)
    MODEL_SCORES[$MODEL]="$SCORE/${#QUESTIONS[@]} ($PERCENTAGE%)"
    echo -e "\n📊 $MODEL スコア: ${MODEL_SCORES[$MODEL]}"
  done

  # 総合結果
  echo -e "\n╔═══════════════════════════════════════════════════════════════╗"
  echo "║                     総合評価結果                              ║"
  echo "╚═══════════════════════════════════════════════════════════════╝"
  echo ""

  for MODEL in "${MODELS[@]}"; do
    printf "%-20s : %s\n" "$MODEL" "${MODEL_SCORES[$MODEL]}"
  done

  echo -e "\n完了時刻: $(date)"
} > "$OUTPUT_FILE"

echo "✅ テスト完了: 結果は $OUTPUT_FILE に保存されました"