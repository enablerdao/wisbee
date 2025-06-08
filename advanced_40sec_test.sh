#!/usr/bin/env bash
set -euo pipefail

# タイムスタンプ付きファイル名
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
OUTPUT_FILE="advanced_test_results_${TIMESTAMP}.txt"

# 開始時刻
START_TIME=$(date +%s)

# 全モデルをテスト
MODELS=(
  "gemma3:4b"
  "qwen3:latest"
  "llava:7b"
  "jaahas/qwen3-abliterated:0.6b"
)

# より高度な質問
declare -A QUESTIONS=(
  ["Q1"]="フィボナッチ数列の最初の10個を答えてください。"
  ["Q2"]="第二次世界大戦が終結した年と、その時の日本の総理大臣は誰でしたか？"
  ["Q3"]="「機械学習」と「深層学習」の違いを簡潔に説明してください。"
)

# 期待される回答（部分一致）
declare -A EXPECTED=(
  ["Q1"]="0.*1.*1.*2.*3.*5.*8.*13.*21.*34|1.*1.*2.*3.*5.*8.*13.*21.*34.*55"
  ["Q2"]="1945.*鈴木貫太郎"
  ["Q3"]="機械学習.*深層学習|深層学習.*機械学習.*一部|ニューラルネットワーク"
)

{
  echo "🎯 高度な問題によるモデルテスト (1問40秒制限)"
  echo "開始時刻: $(date)"
  echo "=============================================="
  
  # 結果集計用
  declare -A MODEL_SCORES
  declare -A MODEL_TIMES
  declare -A MODEL_DETAILS
  declare -A ANSWER_QUALITY
  
  for MODEL in "${MODELS[@]}"; do
    echo -e "\n📦 MODEL: $MODEL"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    MODEL_START=$(date +%s)
    SCORE=0
    DETAILS=""
    TOTAL_Q_TIME=0
    
    for KEY in "${!QUESTIONS[@]}"; do
      Q="${QUESTIONS[$KEY]}"
      echo -e "\n🔍 $KEY: $Q"
      
      Q_START=$(date +%s)
      
      # 1問あたり最大40秒、トークン数を増やす
      RESP=$(curl -s --max-time 40 http://localhost:11434/api/generate \
        -d "{\"model\":\"$MODEL\",\"prompt\":\"$Q\",\"stream\":false,\"options\":{\"temperature\":0.2,\"num_predict\":150}}" \
        2>/dev/null | jq -r '.response // "TIMEOUT"' 2>/dev/null || echo "ERROR")
      
      Q_END=$(date +%s)
      Q_TIME=$((Q_END - Q_START))
      TOTAL_Q_TIME=$((TOTAL_Q_TIME + Q_TIME))
      
      # 応答を整形（高度な問題なので100文字まで表示）
      RESP_CLEAN=$(echo "$RESP" | tr '\n' ' ' | sed 's/  */ /g' | sed 's/^ *//;s/ *$//')
      RESP_SHORT="${RESP_CLEAN:0:100}"
      
      # 評価
      if [[ "$RESP" =~ ${EXPECTED[$KEY]} ]]; then
        echo "✅ 正解: $RESP_SHORT... (${Q_TIME}秒)"
        ((SCORE++))
        DETAILS+="$KEY:✅(${Q_TIME}s) "
        
        # 回答の質を評価
        case $KEY in
          Q1) 
            if [[ "$RESP" =~ "0.*1.*1.*2.*3.*5.*8.*13.*21.*34" ]]; then
              ANSWER_QUALITY[$MODEL]+="Q1:完璧 "
            else
              ANSWER_QUALITY[$MODEL]+="Q1:部分的 "
            fi
            ;;
          Q2)
            if [[ "$RESP" =~ "1945" ]] && [[ "$RESP" =~ "鈴木貫太郎" ]]; then
              ANSWER_QUALITY[$MODEL]+="Q2:完璧 "
            elif [[ "$RESP" =~ "1945" ]]; then
              ANSWER_QUALITY[$MODEL]+="Q2:年のみ "
            else
              ANSWER_QUALITY[$MODEL]+="Q2:部分的 "
            fi
            ;;
          Q3)
            if [[ "$RESP" =~ "ニューラルネットワーク" ]] || [[ "$RESP" =~ "深層" ]]; then
              ANSWER_QUALITY[$MODEL]+="Q3:詳細 "
            else
              ANSWER_QUALITY[$MODEL]+="Q3:基本的 "
            fi
            ;;
        esac
      else
        echo "❌ 不正解: $RESP_SHORT... (${Q_TIME}秒)"
        DETAILS+="$KEY:❌(${Q_TIME}s) "
        ANSWER_QUALITY[$MODEL]+="$KEY:失敗 "
      fi
      
      # 40秒超過チェック
      if [ $Q_TIME -ge 40 ]; then
        echo "⚠️  40秒タイムアウト!"
      elif [ $Q_TIME -ge 30 ]; then
        echo "⚡ 応答時間が長い (30秒以上)"
      fi
    done
    
    MODEL_END=$(date +%s)
    MODEL_TIME=$((MODEL_END - MODEL_START))
    AVG_TIME=$((TOTAL_Q_TIME / 3))
    
    PERCENTAGE=$(echo "scale=0; $SCORE * 100 / ${#QUESTIONS[@]}" | bc)
    
    echo -e "\n📊 モデル結果:"
    echo "スコア: $SCORE/${#QUESTIONS[@]} (${PERCENTAGE}%)"
    echo "合計時間: ${MODEL_TIME}秒 (平均: ${AVG_TIME}秒/問)"
    echo "詳細: $DETAILS"
    echo "回答品質: ${ANSWER_QUALITY[$MODEL]:-なし}"
    
    # 結果を保存
    MODEL_SCORES[$MODEL]="$SCORE/${#QUESTIONS[@]} (${PERCENTAGE}%)"
    MODEL_TIMES[$MODEL]="${MODEL_TIME}秒 (平均${AVG_TIME}秒)"
    MODEL_DETAILS[$MODEL]="$DETAILS"
  done
  
  END_TIME=$(date +%s)
  TOTAL_TIME=$((END_TIME - START_TIME))
  
  echo -e "\n╔════════════════════════════════════════════╗"
  echo "║          高度な問題テスト結果              ║"
  echo "╚════════════════════════════════════════════╝"
  
  echo -e "\n📊 モデル別スコア:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  for MODEL in "${!MODEL_SCORES[@]}"; do
    printf "%-25s : %s\n" "$MODEL" "${MODEL_SCORES[$MODEL]}"
  done
  
  echo -e "\n⏱️  モデル別応答時間:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  for MODEL in "${!MODEL_TIMES[@]}"; do
    printf "%-25s : %s\n" "$MODEL" "${MODEL_TIMES[$MODEL]}"
  done
  
  echo -e "\n📋 回答品質評価:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  for MODEL in "${!ANSWER_QUALITY[@]}"; do
    printf "%-25s : %s\n" "$MODEL" "${ANSWER_QUALITY[$MODEL]}"
  done
  
  echo -e "\n⏱️  総実行時間: ${TOTAL_TIME}秒"
  
  # 総合評価
  echo -e "\n🏆 総合評価:"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  for MODEL in "${!MODEL_SCORES[@]}"; do
    SCORE=$(echo "${MODEL_SCORES[$MODEL]}" | cut -d'/' -f1)
    case $SCORE in
      3) echo "⭐ $MODEL - 優秀！高度な問題に全問正解" ;;
      2) echo "👍 $MODEL - 良好 (2/3正解)" ;;
      1) echo "📌 $MODEL - 基礎的 (1/3正解)" ;;
      0) echo "⚠️  $MODEL - 要強化 (0/3正解)" ;;
    esac
  done
  
  echo -e "\n📝 問題別難易度:"
  echo "Q1: フィボナッチ数列 - アルゴリズム理解"
  echo "Q2: 歴史的事実 - 知識の正確性"
  echo "Q3: 技術概念説明 - 抽象概念の理解"
  
  echo -e "\n終了時刻: $(date)"
} | tee "$OUTPUT_FILE"

echo -e "\n📄 結果保存: $OUTPUT_FILE"