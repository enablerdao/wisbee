#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="conversation_test_results_${TIMESTAMP}.txt"

# 開始時刻
START_TIME=$(date +%s)

# 全モデルをテスト
MODELS=(
  "gemma3:4b"
  "qwen3:latest"
  "llava:7b"
  "jaahas/qwen3-abliterated:0.6b"
)

# 3つのトピックで7ターンの会話
declare -A TOPICS=(
  ["T1"]="料理レシピ"
  ["T2"]="旅行計画"
  ["T3"]="プログラミング学習"
)

# 各トピックの会話フロー
declare -A CONVERSATIONS_T1=(
  ["1"]="カレーライスの作り方を教えてください。"
  ["2"]="必要な材料は何ですか？"
  ["3"]="肉は何がおすすめですか？"
  ["4"]="野菜はどれくらいの大きさに切りますか？"
  ["5"]="カレールーは何を使えばいいですか？"
  ["6"]="隠し味は何か入れますか？"
  ["7"]="最後に、作るときのコツはありますか？"
)

declare -A CONVERSATIONS_T2=(
  ["1"]="京都に旅行に行きたいのですが、おすすめの観光地を教えてください。"
  ["2"]="清水寺はどうやって行けますか？"
  ["3"]="拝観料はいくらですか？"
  ["4"]="近くでおすすめのランチスポットはありますか？"
  ["5"]="お土産は何がおすすめですか？"
  ["6"]="混雑を避けるにはいつ行くのがいいですか？"
  ["7"]="他に近くで行ける観光地はありますか？"
)

declare -A CONVERSATIONS_T3=(
  ["1"]="Pythonを勉強したいのですが、何から始めればいいですか？"
  ["2"]="初心者向けの良い教材はありますか？"
  ["3"]="変数とは何ですか？"
  ["4"]="リストとタプルの違いは何ですか？"
  ["5"]="forループの使い方を教えてください。"
  ["6"]="関数はどうやって定義しますか？"
  ["7"]="エラーが出たときはどう対処すればいいですか？"
)

{
  echo "🗣️ 会話継続性テスト (3トピック×7ターン)"
  echo "開始時刻: $(date)"
  echo "=========================================="
  
  # 結果集計用
  declare -A MODEL_SCORES
  declare -A CONTEXT_QUALITY
  
  for MODEL in "${MODELS[@]}"; do
    echo -e "\n📦 MODEL: $MODEL"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    MODEL_START=$(date +%s)
    TOTAL_SCORE=0
    
    # トピック1: 料理レシピ
    echo -e "\n🍛 トピック1: ${TOPICS[T1]}"
    echo "---"
    CONTEXT=""
    CONTEXT_MAINTAINED=0
    
    for i in {1..7}; do
      Q="${CONVERSATIONS_T1[$i]}"
      echo -e "\nターン$i: $Q"
      
      TURN_START=$(date +%s)
      
      # 会話履歴を含めたプロンプト
      if [ -z "$CONTEXT" ]; then
        PROMPT="$Q"
      else
        PROMPT="$CONTEXT\n\nユーザー: $Q\n\nアシスタント:"
      fi
      
      RESP=$(curl -s --max-time 40 http://localhost:11434/api/generate \
        -d "{\"model\":\"$MODEL\",\"prompt\":\"$PROMPT\",\"stream\":false,\"options\":{\"temperature\":0.3,\"num_predict\":100}}" \
        2>/dev/null | jq -r '.response // "TIMEOUT"' 2>/dev/null || echo "ERROR")
      
      TURN_END=$(date +%s)
      TURN_TIME=$((TURN_END - TURN_START))
      
      # 応答を表示（50文字まで）
      RESP_SHORT=$(echo "$RESP" | tr '\n' ' ' | cut -c1-50)
      echo "→ $RESP_SHORT... (${TURN_TIME}秒)"
      
      # 文脈維持の評価
      case $i in
        2) [[ "$RESP" =~ (材料|ingredient|野菜|肉) ]] && ((CONTEXT_MAINTAINED++)) ;;
        3) [[ "$RESP" =~ (牛|豚|鶏|チキン|ビーフ|ポーク) ]] && ((CONTEXT_MAINTAINED++)) ;;
        4) [[ "$RESP" =~ (切|カット|サイズ|大きさ|cm) ]] && ((CONTEXT_MAINTAINED++)) ;;
        5) [[ "$RESP" =~ (ルー|ルウ|カレー粉|スパイス) ]] && ((CONTEXT_MAINTAINED++)) ;;
        6) [[ "$RESP" =~ (隠し味|チョコ|コーヒー|はちみつ|りんご) ]] && ((CONTEXT_MAINTAINED++)) ;;
        7) [[ "$RESP" =~ (コツ|ポイント|注意|大切) ]] && ((CONTEXT_MAINTAINED++)) ;;
      esac
      
      # 会話履歴を更新
      CONTEXT="$CONTEXT\n\nユーザー: $Q\n\nアシスタント: $RESP"
      
      # タイムアウトチェック
      if [ $TURN_TIME -ge 40 ]; then
        echo "⚠️ タイムアウト!"
      fi
    done
    
    echo "📊 トピック1文脈維持: $CONTEXT_MAINTAINED/6"
    TOTAL_SCORE=$((TOTAL_SCORE + CONTEXT_MAINTAINED))
    
    # トピック2: 旅行計画（簡略版）
    echo -e "\n✈️ トピック2: ${TOPICS[T2]} (簡易チェック)"
    CONTEXT=""
    TRAVEL_SCORE=0
    
    # 最初と最後だけチェック
    Q1="${CONVERSATIONS_T2[1]}"
    RESP1=$(curl -s --max-time 20 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"$Q1\",\"stream\":false,\"options\":{\"temperature\":0.3,\"num_predict\":80}}" \
      2>/dev/null | jq -r '.response // "ERROR"' | tr '\n' ' ')
    
    if [[ "$RESP1" =~ (清水寺|金閣寺|伏見稲荷|嵐山) ]]; then
      ((TRAVEL_SCORE++))
      echo "✅ 観光地提案OK"
    fi
    
    # トピック3: プログラミング（簡易チェック）
    echo -e "\n💻 トピック3: ${TOPICS[T3]} (簡易チェック)"
    Q1="${CONVERSATIONS_T3[1]}"
    RESP1=$(curl -s --max-time 20 http://localhost:11434/api/generate \
      -d "{\"model\":\"$MODEL\",\"prompt\":\"$Q1\",\"stream\":false,\"options\":{\"temperature\":0.3,\"num_predict\":80}}" \
      2>/dev/null | jq -r '.response // "ERROR"' | tr '\n' ' ')
    
    if [[ "$RESP1" =~ (基礎|基本|入門|初心者|環境構築) ]]; then
      ((TRAVEL_SCORE++))
      echo "✅ 学習アドバイスOK"
    fi
    
    TOTAL_SCORE=$((TOTAL_SCORE + TRAVEL_SCORE))
    
    MODEL_END=$(date +%s)
    MODEL_TIME=$((MODEL_END - MODEL_START))
    
    # スコア計算（最大8点）
    PERCENTAGE=$(echo "scale=0; $TOTAL_SCORE * 100 / 8" | bc)
    
    echo -e "\n📊 モデル総合評価:"
    echo "スコア: $TOTAL_SCORE/8 (${PERCENTAGE}%)"
    echo "実行時間: ${MODEL_TIME}秒"
    
    MODEL_SCORES[$MODEL]="$TOTAL_SCORE/8 (${PERCENTAGE}%)"
    
    # 文脈維持品質
    if [ $CONTEXT_MAINTAINED -ge 5 ]; then
      CONTEXT_QUALITY[$MODEL]="優秀"
    elif [ $CONTEXT_MAINTAINED -ge 3 ]; then
      CONTEXT_QUALITY[$MODEL]="良好"
    else
      CONTEXT_QUALITY[$MODEL]="要改善"
    fi
  done
  
  END_TIME=$(date +%s)
  TOTAL_TIME=$((END_TIME - START_TIME))
  
  echo -e "\n╔════════════════════════════════════════╗"
  echo "║        会話継続性テスト結果            ║"
  echo "╚════════════════════════════════════════╝"
  
  echo -e "\n📊 モデル別スコア:"
  for MODEL in "${!MODEL_SCORES[@]}"; do
    printf "%-25s : %s\n" "$MODEL" "${MODEL_SCORES[$MODEL]}"
  done
  
  echo -e "\n💬 文脈維持能力:"
  for MODEL in "${!CONTEXT_QUALITY[@]}"; do
    printf "%-25s : %s\n" "$MODEL" "${CONTEXT_QUALITY[$MODEL]}"
  done
  
  echo -e "\n⏱️ 総実行時間: ${TOTAL_TIME}秒"
  
  echo -e "\n🏆 評価基準:"
  echo "• 6-8点: 優秀な会話継続性"
  echo "• 4-5点: 基本的な文脈理解"
  echo "• 0-3点: 文脈維持に課題あり"
  
  echo -e "\n終了時刻: $(date)"
} | tee "$OUTPUT_FILE"

echo -e "\n📄 結果保存: $OUTPUT_FILE"