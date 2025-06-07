#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="practical_tasks_results_${TIMESTAMP}.txt"

# 開始時刻
START_TIME=$(date +%s)

# テスト対象モデル（高速なものを選択）
MODELS=(
  "gemma3:4b"
  "phi3:mini"
  "llama3.2:1b"
)

# 実用的なタスク
declare -A PRACTICAL_TASKS=(
  ["P1"]="メールの件名を考えて: 会議の日程変更について同僚に連絡"
  ["P2"]="ToDo リストを作って: 明日の出張準備"
  ["P3"]="商品レビューを要約: 「このイヤホンは音質が素晴らしく、特に低音がクリアです。ただしケーブルが少し短いのが残念。価格を考えると十分満足できる製品です。」"
  ["P4"]="エラーメッセージを説明: 「Error: Cannot read property 'length' of undefined」"
  ["P5"]="レシピを簡略化: 「鶏肉に塩コショウをして、フライパンで両面を焼き、最後に醤油とみりんを加えて煮詰める」"
)

# 評価キーワード
declare -A PRACTICAL_EXPECTED=(
  ["P1"]="会議|日程|変更|reschedule|meeting"
  ["P2"]="準備|パック|チェック|確認|予約"
  ["P3"]="音質|良|短い|満足|価格"
  ["P4"]="undefined|定義されて|エラー|length|プロパティ"
  ["P5"]="鶏|焼|醤油|みりん|照り焼き"
)

{
  echo "💼 実用タスクテスト"
  echo "開始時刻: $(date)"
  echo "==================="
  echo ""
  
  declare -A MODEL_SCORES
  declare -A USEFULNESS_SCORES
  
  for MODEL in "${MODELS[@]}"; do
    echo "📦 MODEL: $MODEL"
    echo "---"
    
    MODEL_START=$(date +%s)
    SCORE=0
    USEFULNESS=0
    
    for KEY in "${!PRACTICAL_TASKS[@]}"; do
      TASK="${PRACTICAL_TASKS[$KEY]}"
      echo ""
      echo "📋 $KEY: ${TASK:0:50}..."
      
      Q_START=$(date +%s)
      
      RESP=$(curl -s --max-time 15 http://localhost:11434/api/generate \
        -d "{\"model\":\"$MODEL\",\"prompt\":\"$TASK\",\"stream\":false,\"options\":{\"temperature\":0.3,\"num_predict\":80}}" \
        2>/dev/null | jq -r '.response // "TIMEOUT"' 2>/dev/null || echo "ERROR")
      
      Q_END=$(date +%s)
      Q_TIME=$((Q_END - Q_START))
      
      # <think>タグを除去
      RESP_CLEAN=$(echo "$RESP" | sed 's/<think>.*<\/think>//g' | sed 's/<think>.*//g')
      RESP_SHORT=$(echo "$RESP_CLEAN" | tr '\n' ' ' | cut -c1-70)
      
      # 基本評価
      if [[ "$RESP_CLEAN" =~ ${PRACTICAL_EXPECTED[$KEY]} ]]; then
        echo "✅ 適切: $RESP_SHORT... (${Q_TIME}秒)"
        ((SCORE++))
        
        # 実用性評価
        case $KEY in
          P1) # メール件名
            if [[ "$RESP_CLEAN" =~ (【|】|:) ]]; then
              ((USEFULNESS++))
              echo "   📧 フォーマット良好"
            fi
            ;;
          P2) # ToDoリスト
            if [[ "$RESP_CLEAN" =~ (・|□|-|[0-9]\.) ]]; then
              ((USEFULNESS++))
              echo "   ✓ リスト形式"
            fi
            ;;
          P3) # 要約
            if [[ ${#RESP_CLEAN} -lt 150 ]]; then
              ((USEFULNESS++))
              echo "   📝 簡潔な要約"
            fi
            ;;
          P4) # エラー説明
            if [[ "$RESP_CLEAN" =~ (解決|対処|確認) ]]; then
              ((USEFULNESS++))
              echo "   💡 解決策あり"
            fi
            ;;
          P5) # レシピ簡略化
            if [[ ${#RESP_CLEAN} -lt 100 ]]; then
              ((USEFULNESS++))
              echo "   🍳 簡潔化成功"
            fi
            ;;
        esac
      else
        echo "❌ 不適切: $RESP_SHORT... (${Q_TIME}秒)"
      fi
    done
    
    MODEL_END=$(date +%s)
    MODEL_TIME=$((MODEL_END - MODEL_START))
    
    PERCENTAGE=$(echo "scale=0; $SCORE * 100 / ${#PRACTICAL_TASKS[@]}" | bc)
    USEFULNESS_PCT=$(echo "scale=0; $USEFULNESS * 100 / ${#PRACTICAL_TASKS[@]}" | bc)
    
    echo ""
    echo "📊 結果:"
    echo "基本スコア: $SCORE/${#PRACTICAL_TASKS[@]} (${PERCENTAGE}%)"
    echo "実用性: $USEFULNESS/${#PRACTICAL_TASKS[@]} (${USEFULNESS_PCT}%)"
    echo "実行時間: ${MODEL_TIME}秒"
    echo ""
    
    MODEL_SCORES[$MODEL]="$SCORE/${#PRACTICAL_TASKS[@]} (${PERCENTAGE}%)"
    USEFULNESS_SCORES[$MODEL]="$USEFULNESS/${#PRACTICAL_TASKS[@]} (${USEFULNESS_PCT}%)"
  done
  
  END_TIME=$(date +%s)
  TOTAL_TIME=$((END_TIME - START_TIME))
  
  echo "╔════════════════════════════════════════╗"
  echo "║       実用タスクテスト結果             ║"
  echo "╚════════════════════════════════════════╝"
  echo ""
  
  echo "📊 総合評価:"
  for MODEL in "${!MODEL_SCORES[@]}"; do
    printf "%-15s : 基本 %s / 実用性 %s\n" "$MODEL" "${MODEL_SCORES[$MODEL]}" "${USEFULNESS_SCORES[$MODEL]}"
  done
  
  echo ""
  echo "⏱️ 総実行時間: ${TOTAL_TIME}秒"
  echo ""
  
  # 実用性ランキング
  echo "🏆 実用性ランキング:"
  for MODEL in "${!MODEL_SCORES[@]}"; do
    BASIC=$(echo "${MODEL_SCORES[$MODEL]}" | cut -d'/' -f1)
    USEFUL=$(echo "${USEFULNESS_SCORES[$MODEL]}" | cut -d'/' -f1)
    TOTAL=$((BASIC + USEFUL))
    echo "$TOTAL $MODEL"
  done | sort -rn | head -3 | while read TOTAL MODEL; do
    if [ $TOTAL -ge 8 ]; then
      echo "🥇 $MODEL - 非常に実用的"
    elif [ $TOTAL -ge 6 ]; then
      echo "🥈 $MODEL - 実用的"
    else
      echo "🥉 $MODEL - まずまず実用的"
    fi
  done
  
  echo ""
  echo "終了時刻: $(date)"
} | tee "$OUTPUT_FILE"

echo ""
echo "📄 結果保存: $OUTPUT_FILE"