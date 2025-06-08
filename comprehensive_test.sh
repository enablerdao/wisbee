#!/usr/bin/env bash
set -euo pipefail

# モデルリスト
MODELS=(
  "gemma3:1b"
  "llava:7b"
  "qwen3:latest"
  "gemma3:4b"
)

# カテゴリーと質問
declare -A CATEGORIES=(
  ["基礎知識"]="日本の首都はどこですか？|1+1は？|水は何度で凍りますか？"
  ["日本文化"]="徳川家康は何をした人物ですか？|桜の花は何月頃に咲きますか？"
  ["論理推論"]="りんごが5個あって3個食べました。残りは何個？|AがBより大きく、BがCより大きい時、AとCの関係は？"
  ["言語理解"]="「嬉しい」の反対語は？|「ありがとう」をもっと丁寧に言うと？"
  ["指示実行"]="1から5までの数字を逆順に並べてください。|「はい」か「いいえ」で答えてください：日本は島国ですか？"
)

# 結果格納用
declare -A SCORES
declare -A RESPONSES

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║           包括的日本語モデル精度テスト                        ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# 各モデルでテスト
for MODEL in "${MODELS[@]}"; do
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "🤖 MODEL: $MODEL"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  TOTAL_SCORE=0
  QUESTION_COUNT=0
  
  for CATEGORY in "${!CATEGORIES[@]}"; do
    echo -e "\n📚 カテゴリー: $CATEGORY"
    IFS='|' read -ra QUESTIONS <<< "${CATEGORIES[$CATEGORY]}"
    
    for Q in "${QUESTIONS[@]}"; do
      echo -e "\n  ❓ $Q"
      
      # API呼び出し
      RESP=$(curl -s http://localhost:11434/api/generate \
        -d "{\"model\":\"$MODEL\",\"prompt\":\"$Q\",\"stream\":false,\"options\":{\"num_predict\":50}}" \
        | jq -r '.response // "ERROR"')
      
      # 回答を表示（最初の100文字まで）
      if [ ${#RESP} -gt 100 ]; then
        echo "  💬 ${RESP:0:100}..."
      else
        echo "  💬 $RESP"
      fi
      
      # 簡易採点（正解判定）
      SCORE=0
      case "$Q" in
        "日本の首都はどこですか？")
          [[ "$RESP" =~ 東京 ]] && SCORE=1 ;;
        "1+1は？")
          [[ "$RESP" =~ 2 ]] && SCORE=1 ;;
        "水は何度で凍りますか？")
          [[ "$RESP" =~ 0|０|零 ]] && SCORE=1 ;;
        "りんごが5個あって3個食べました。残りは何個？")
          [[ "$RESP" =~ 2|２|二 ]] && SCORE=1 ;;
        "「嬉しい」の反対語は？")
          [[ "$RESP" =~ 悲|哀 ]] && SCORE=1 ;;
        "「はい」か「いいえ」で答えてください：日本は島国ですか？")
          [[ "$RESP" =~ はい ]] && SCORE=1 ;;
      esac
      
      if [ $SCORE -eq 1 ]; then
        echo "  ✅ 正解"
      else
        echo "  ❌ 不正解"
      fi
      
      TOTAL_SCORE=$((TOTAL_SCORE + SCORE))
      QUESTION_COUNT=$((QUESTION_COUNT + 1))
    done
  done
  
  # モデルごとの集計
  ACCURACY=$(echo "scale=1; $TOTAL_SCORE * 100 / $QUESTION_COUNT" | bc)
  echo -e "\n📊 $MODEL の成績: $TOTAL_SCORE/$QUESTION_COUNT (${ACCURACY}%)"
  SCORES[$MODEL]=$ACCURACY
done

# 全体サマリー
echo -e "\n╔═══════════════════════════════════════════════════════════════╗"
echo "║                        総合結果                               ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "モデル別正答率:"
for MODEL in "${MODELS[@]}"; do
  printf "  %-20s : %5s%%\n" "$MODEL" "${SCORES[$MODEL]}"
done

# 精度向上の提案
echo -e "\n💡 精度向上のための提案:"
echo "1. プロンプトエンジニアリング:"
echo "   - より具体的な指示を追加（例：「簡潔に答えてください」）"
echo "   - Few-shot例を含める"
echo "   - 出力フォーマットを指定"
echo ""
echo "2. モデル設定の調整:"
echo "   - temperature を下げて確定的な回答を促す"
echo "   - top_p や top_k を調整"
echo "   - num_predict を質問に応じて調整"
echo ""
echo "3. 後処理:"
echo "   - 回答から不要な部分を除去"
echo "   - 複数回実行して最頻値を採用"
echo "   - 回答の検証ロジックを追加"