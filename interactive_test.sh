#!/bin/bash

# Interactive Ollama Model Testing Script
# リアルタイムでモデルの出力を見ながらテストできるスクリプト

set -euo pipefail

# Color codes for better readability
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Default models
DEFAULT_MODELS=("llama3.2:1b" "phi3:mini" "qwen3:latest" "gemma3:4b" "gemma3:1b")

# Function to print colored text
print_color() {
    local color=$1
    local text=$2
    echo -e "${color}${text}${NC}"
}

# Function to test a single prompt with a model
test_prompt() {
    local model=$1
    local prompt=$2
    local max_tokens=${3:-100}
    
    print_color "$CYAN" "\n🤖 Model: $model"
    print_color "$YELLOW" "📝 Prompt: $prompt"
    print_color "$BLUE" "⏳ Generating response..."
    
    # Send request to Ollama
    local response=$(curl -s http://localhost:11434/api/generate \
        -d "{
            \"model\": \"$model\",
            \"prompt\": \"$prompt\",
            \"stream\": false,
            \"options\": {
                \"temperature\": 0.7,
                \"num_predict\": $max_tokens
            }
        }" | jq -r '.response // "Error: No response"')
    
    print_color "$GREEN" "✅ Response:"
    echo "$response"
    echo "----------------------------------------"
}

# Function to run predefined prompt categories
run_category() {
    local category=$1
    local model=$2
    
    case $category in
        "creative")
            local prompts=(
                "新しい色を発明して、その名前と説明をしてください。"
                "もし重力が逆だったら世界はどうなる？"
                "AIとして感じる『寂しさ』を詩で表現してください。"
            )
            ;;
        "logic")
            local prompts=(
                "もし全ての猫が動物で、全ての動物が生き物なら、全ての猫は何ですか？"
                "3人が3個のケーキを3分で食べます。9人が9個のケーキを食べるのに何分かかりますか？"
                "赤、青、緑の箱があります。赤の箱には青いボールが、青の箱には緑のボールが入っています。緑の箱には何色のボールが入っていますか？"
            )
            ;;
        "math")
            local prompts=(
                "25 × 4 = ?"
                "次の数列の次の数は？ 2, 6, 12, 20, ?"
                "1から100までの偶数の合計は？"
            )
            ;;
        "code")
            local prompts=(
                "Pythonで1から10までの数字を出力するコードを書いてください。"
                "JavaScriptで配列の要素を逆順にする関数を書いてください。"
                "SQLで年齢が20歳以上のユーザーを選択するクエリを書いてください。"
            )
            ;;
        "japanese")
            local prompts=(
                "『春はあけぼの』で始まる文章の続きを書いてください。"
                "日本の四季それぞれの特徴を簡潔に説明してください。"
                "俳句を一つ作ってください。季語を含めてください。"
            )
            ;;
        *)
            print_color "$RED" "Unknown category: $category"
            return
            ;;
    esac
    
    for prompt in "${prompts[@]}"; do
        test_prompt "$model" "$prompt" 150
    done
}

# Main menu
show_menu() {
    clear
    print_color "$PURPLE" "🚀 Interactive Ollama Model Tester"
    print_color "$CYAN" "==================================\n"
    echo "1) Test single prompt with all models"
    echo "2) Test single prompt with specific model"
    echo "3) Run creative prompts"
    echo "4) Run logic puzzles"
    echo "5) Run math problems"
    echo "6) Run coding tasks"
    echo "7) Run Japanese language tests"
    echo "8) Free chat mode"
    echo "9) Compare models side-by-side"
    echo "0) Exit"
    echo ""
}

# Free chat mode
free_chat() {
    local model=$1
    print_color "$GREEN" "\n💬 Free chat mode with $model"
    print_color "$YELLOW" "Type 'exit' to return to menu\n"
    
    while true; do
        echo -n "You: "
        read -r user_input
        
        if [[ "$user_input" == "exit" ]]; then
            break
        fi
        
        test_prompt "$model" "$user_input" 200
    done
}

# Compare models side by side
compare_models() {
    echo -n "Enter your prompt: "
    read -r prompt
    
    echo -n "Max tokens (default 100): "
    read -r max_tokens
    max_tokens=${max_tokens:-100}
    
    print_color "$PURPLE" "\n📊 Comparing all models with prompt: $prompt\n"
    
    for model in "${DEFAULT_MODELS[@]}"; do
        test_prompt "$model" "$prompt" "$max_tokens"
    done
}

# Main loop
while true; do
    show_menu
    echo -n "Select option: "
    read -r choice
    
    case $choice in
        1)
            echo -n "Enter your prompt: "
            read -r prompt
            for model in "${DEFAULT_MODELS[@]}"; do
                test_prompt "$model" "$prompt" 150
            done
            echo -n "\nPress Enter to continue..."
            read -r
            ;;
        2)
            echo "Available models:"
            for i in "${!DEFAULT_MODELS[@]}"; do
                echo "$((i+1))) ${DEFAULT_MODELS[$i]}"
            done
            echo -n "Select model number: "
            read -r model_num
            if [[ $model_num -ge 1 && $model_num -le ${#DEFAULT_MODELS[@]} ]]; then
                model="${DEFAULT_MODELS[$((model_num-1))]}"
                echo -n "Enter your prompt: "
                read -r prompt
                test_prompt "$model" "$prompt" 150
            else
                print_color "$RED" "Invalid selection"
            fi
            echo -n "\nPress Enter to continue..."
            read -r
            ;;
        3|4|5|6|7)
            categories=("" "" "creative" "logic" "math" "code" "japanese")
            category="${categories[$choice]}"
            echo "Testing $category prompts with all models..."
            for model in "${DEFAULT_MODELS[@]}"; do
                run_category "$category" "$model"
            done
            echo -n "\nPress Enter to continue..."
            read -r
            ;;
        8)
            echo "Available models:"
            for i in "${!DEFAULT_MODELS[@]}"; do
                echo "$((i+1))) ${DEFAULT_MODELS[$i]}"
            done
            echo -n "Select model number: "
            read -r model_num
            if [[ $model_num -ge 1 && $model_num -le ${#DEFAULT_MODELS[@]} ]]; then
                model="${DEFAULT_MODELS[$((model_num-1))]}"
                free_chat "$model"
            else
                print_color "$RED" "Invalid selection"
            fi
            ;;
        9)
            compare_models
            echo -n "\nPress Enter to continue..."
            read -r
            ;;
        0)
            print_color "$GREEN" "\n👋 Goodbye!"
            exit 0
            ;;
        *)
            print_color "$RED" "Invalid option. Please try again."
            sleep 1
            ;;
    esac
done