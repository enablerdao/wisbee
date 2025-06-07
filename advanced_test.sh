#!/usr/bin/env bash
set -euo pipefail

# モデルリスト（テスト用に3つに絞る）
MODELS=(
  "gemma3:1b"
  "gemma3:4b"
  "llava:7b"
)

# 質問サンプル（高精度テスト用に5問選択）
declare -A QUESTIONS=(
  ["Q1"]="地球から月までの平均距離は、現在最も正確な推定値で約何kmですか？"
  ["Q2"]="「人工知能」と「機械学習」の違いを、初心者でも理解できるように簡潔に一文で説明してください。"
  ["Q3"]="日本の47都道府県を五十音順に並べたとき、最初の3つを正しく挙げてください。"
  ["Q4"]="配列 [5, 2, 9, 1, 5, 6] をPythonコードで昇順にソートして、結果を表示するプログラムを示してください。"
  ["Q5"]="季語に「桜」を含め、春の情景が鮮明に伝わるような俳句を1句作ってください。"
)

# 期待される回答のキーワード
declare -A EXPECTED=(
  ["Q1"]="384|38万"
  ["Q2"]="人工知能.*機械学習|機械学習.*一部"
  ["Q3"]="愛知.*青森.*秋田"
  ["Q4"]="sort|sorted|\\[1, 2, 5, 5, 6, 9\\]"
  ["Q5"]="桜.*五七五"
)

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║               高精度日本語モデルテスト                        ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
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
    
    # API呼び出し（プロンプト最適化版）
    PROMPT="あなたは正確で簡潔な回答を心がけるアシスタントです。次の質問に対して、的確に答えてください。\n\n質問: $Q\n\n回答:"
    
    RESP=$(curl -s http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"$PROMPT\",\"stream\":false,\"options\":{\"temperature\":0.3,\"num_predict\":150}}" \
      | jq -r '.response // "ERROR"')
    
    # 回答表示（最初の150文字）
    if [ ${#RESP} -gt 150 ]; then
      echo "💬 ${RESP:0:150}..."
    else
      echo "💬 $RESP"
    fi
    
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

# 改善提案
echo -e "\n💡 精度向上のための具体的改善策:"
echo ""
echo "1. プロンプトエンジニアリング:"
echo "   - システムプロンプトで役割を明確化"
echo "   - 出力形式を具体的に指定（例：「～について、以下の形式で答えてください」）"
echo "   - Few-shot学習の活用"
echo ""
echo "2. モデルパラメータ最適化:"
echo "   - temperature: 0.1-0.3（事実確認系）"
echo "   - top_p: 0.9（創造的タスク）"
echo "   - repeat_penalty: 1.1（繰り返し防止）"
echo ""
echo "3. 前処理・後処理:"
echo "   - 入力の正規化（全角半角統一）"
echo "   - 出力のパターンマッチング改善"
echo "   - 複数回実行による安定性向上"