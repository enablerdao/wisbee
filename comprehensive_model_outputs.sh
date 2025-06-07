#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="comprehensive_model_outputs_${TIMESTAMP}.txt"

# 開始時刻
START_TIME=$(date +%s)

# テスト対象モデル
MODELS=(
  "gemma3:4b"
  "qwen3:latest"
  "phi3:mini"
  "llama3.2:1b"
  "gemma3:1b"
  "llava:7b"
)

# 多様な質問セット
declare -A TEST_PROMPTS=(
  ["P1"]="日本の四季について、それぞれの特徴を簡潔に説明してください。"
  ["P2"]="次のコードのエラーを修正してください: def add(a, b) return a + b"
  ["P3"]="「時は金なり」ということわざの意味を現代的な例で説明してください。"
  ["P4"]="1から100までの数字のうち、3の倍数と5の倍数の合計を求める方法を説明してください。"
  ["P5"]="AIが人間の仕事を奪うという懸念について、あなたの考えを述べてください。"
)

{
  echo "📝 包括的モデル出力テスト"
  echo "実行日時: $(date)"
  echo "=================================="
  echo ""
  echo "各モデルの実際の生成テキストを記録します"
  echo ""
  
  for MODEL in "${MODELS[@]}"; do
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║ MODEL: $MODEL"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    MODEL_START=$(date +%s)
    
    # 各プロンプトに対する回答を取得
    for KEY in "${!TEST_PROMPTS[@]}"; do
      PROMPT="${TEST_PROMPTS[$KEY]}"
      
      echo "┌─────────────────────────────────────────────────────────────┐"
      echo "│ $KEY: ${PROMPT:0:60}..."
      echo "└─────────────────────────────────────────────────────────────┘"
      echo ""
      
      Q_START=$(date +%s)
      
      # モデルに応じて適切なパラメータを設定
      case $KEY in
        P1|P3|P5)
          TEMP=0.5
          TOKENS=200
          ;;
        P2|P4)
          TEMP=0.1
          TOKENS=150
          ;;
      esac
      
      # API呼び出し
      RESPONSE=$(curl -s --max-time 25 http://localhost:11434/api/generate \
        -d "{\"model\":\"$MODEL\",\"prompt\":\"$PROMPT\",\"stream\":false,\"options\":{\"temperature\":$TEMP,\"num_predict\":$TOKENS}}" \
        2>/dev/null | jq -r '.response // "TIMEOUT"' 2>/dev/null || echo "ERROR")
      
      Q_END=$(date +%s)
      Q_TIME=$((Q_END - Q_START))
      
      # 生成されたテキストを完全に表示
      echo "【生成されたテキスト】"
      echo "----------------------------------------"
      echo "$RESPONSE"
      echo "----------------------------------------"
      echo ""
      echo "⏱️ 生成時間: ${Q_TIME}秒"
      echo "📏 文字数: $(echo -n "$RESPONSE" | wc -c)"
      echo ""
      
      # 品質評価
      case $KEY in
        P1) # 四季
          SEASONS=$(echo "$RESPONSE" | grep -E "春|夏|秋|冬" | wc -l)
          echo "🌸 季節の言及: $SEASONS/4"
          ;;
        P2) # コード修正
          if [[ "$RESPONSE" =~ ":" ]]; then
            echo "✅ 構文エラーを認識"
          fi
          ;;
        P3) # ことわざ
          if [[ "$RESPONSE" =~ (例|たとえ|具体的) ]]; then
            echo "✅ 具体例あり"
          fi
          ;;
        P4) # 数学
          if [[ "$RESPONSE" =~ (FizzBuzz|3.*5|倍数) ]]; then
            echo "✅ 問題を正しく理解"
          fi
          ;;
        P5) # AI議論
          WORD_COUNT=$(echo "$RESPONSE" | wc -w)
          echo "📝 単語数: $WORD_COUNT"
          ;;
      esac
      
      echo ""
    done
    
    MODEL_END=$(date +%s)
    MODEL_TIME=$((MODEL_END - MODEL_START))
    
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 $MODEL の総処理時間: ${MODEL_TIME}秒"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo ""
  done
  
  END_TIME=$(date +%s)
  TOTAL_TIME=$((END_TIME - START_TIME))
  
  echo "══════════════════════════════════════════"
  echo "⏱️ 全体実行時間: ${TOTAL_TIME}秒"
  echo "📅 終了時刻: $(date)"
  echo "══════════════════════════════════════════"
} | tee "$OUTPUT_FILE"

echo ""
echo "📄 全ての生成テキストは以下のファイルに保存されました:"
echo "→ $OUTPUT_FILE"