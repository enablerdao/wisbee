#!/usr/bin/env python3
"""
Ollama Code - Claude Code風CLIツール
シンプルで高速なローカルLLMコーディングアシスタント
"""

import os
import sys
import json
import time
import subprocess
import argparse
import hashlib
from pathlib import Path
from datetime import datetime
from typing import List, Dict, Optional, Tuple
import requests
import re
import glob
import difflib

# Configuration
CONFIG_FILE = Path.home() / ".ocode" / "config.json"
HISTORY_FILE = Path.home() / ".ocode" / "history.jsonl"
DEFAULT_MODEL = "qwen3:1.7b"
OLLAMA_URL = "http://localhost:11434"

# ANSI Colors
class Colors:
    BLUE = '\033[94m'
    GREEN = '\033[92m'
    YELLOW = '\033[93m'
    RED = '\033[91m'
    GRAY = '\033[90m'
    BOLD = '\033[1m'
    END = '\033[0m'

class OllamaCode:
    def __init__(self):
        self.config = self.load_config()
        self.model = self.config.get("model", DEFAULT_MODEL)
        self.context = []
        self.project_root = Path.cwd()
        self.conversation_id = hashlib.md5(str(time.time()).encode()).hexdigest()[:8]
        
    def load_config(self) -> dict:
        """設定ファイルの読み込み"""
        if CONFIG_FILE.exists():
            with open(CONFIG_FILE, 'r') as f:
                return json.load(f)
        return {
            "model": DEFAULT_MODEL,
            "max_tokens": 4000,
            "temperature": 0.7,
            "thinking_mode": "balanced"
        }
    
    def save_config(self):
        """設定の保存"""
        CONFIG_FILE.parent.mkdir(parents=True, exist_ok=True)
        with open(CONFIG_FILE, 'w') as f:
            json.dump(self.config, f, indent=2)
    
    def log_history(self, entry: dict):
        """実行履歴の記録"""
        HISTORY_FILE.parent.mkdir(parents=True, exist_ok=True)
        with open(HISTORY_FILE, 'a') as f:
            f.write(json.dumps(entry, ensure_ascii=False) + '\n')
    
    def print_colored(self, text: str, color: str = ""):
        """色付きテキストの出力"""
        print(f"{color}{text}{Colors.END}")
    
    def get_project_structure(self, max_depth: int = 3) -> str:
        """プロジェクト構造の取得"""
        structure = []
        for root, dirs, files in os.walk(self.project_root):
            level = root.replace(str(self.project_root), '').count(os.sep)
            if level > max_depth:
                continue
            indent = ' ' * 2 * level
            structure.append(f"{indent}{os.path.basename(root)}/")
            sub_indent = ' ' * 2 * (level + 1)
            for file in sorted(files)[:10]:  # 最大10ファイル
                if not file.startswith('.'):
                    structure.append(f"{sub_indent}{file}")
        return '\n'.join(structure[:50])  # 最大50行
    
    def read_file(self, filepath: str) -> Optional[str]:
        """ファイルの読み込み"""
        try:
            path = Path(filepath)
            if not path.is_absolute():
                path = self.project_root / path
            if path.exists() and path.is_file():
                with open(path, 'r', encoding='utf-8') as f:
                    return f.read()
        except Exception as e:
            self.print_colored(f"ファイル読み込みエラー: {e}", Colors.RED)
        return None
    
    def write_file(self, filepath: str, content: str) -> bool:
        """ファイルの書き込み"""
        try:
            path = Path(filepath)
            if not path.is_absolute():
                path = self.project_root / path
            path.parent.mkdir(parents=True, exist_ok=True)
            with open(path, 'w', encoding='utf-8') as f:
                f.write(content)
            self.print_colored(f"✓ ファイルを保存: {filepath}", Colors.GREEN)
            return True
        except Exception as e:
            self.print_colored(f"ファイル書き込みエラー: {e}", Colors.RED)
            return False
    
    def run_command(self, command: str) -> Tuple[bool, str]:
        """コマンドの実行"""
        try:
            result = subprocess.run(
                command, 
                shell=True, 
                capture_output=True, 
                text=True,
                timeout=30
            )
            output = result.stdout + result.stderr
            return result.returncode == 0, output
        except subprocess.TimeoutExpired:
            return False, "コマンドタイムアウト"
        except Exception as e:
            return False, str(e)
    
    def search_files(self, pattern: str, file_pattern: str = "**/*") -> List[str]:
        """ファイル内容の検索"""
        matches = []
        for filepath in glob.glob(str(self.project_root / file_pattern), recursive=True):
            if os.path.isfile(filepath):
                try:
                    with open(filepath, 'r', encoding='utf-8') as f:
                        content = f.read()
                        if re.search(pattern, content, re.IGNORECASE):
                            matches.append(filepath)
                except:
                    pass
        return matches[:10]  # 最大10件
    
    def git_operation(self, operation: str) -> Tuple[bool, str]:
        """Git操作の実行"""
        git_commands = {
            "status": "git status --short",
            "diff": "git diff",
            "add": "git add .",
            "commit": "git commit -m",
            "branch": "git branch",
            "log": "git log --oneline -10"
        }
        
        if operation in git_commands:
            return self.run_command(git_commands[operation])
        return False, "不明なGit操作"
    
    def call_ollama(self, prompt: str, system_prompt: str = "") -> str:
        """Ollama APIの呼び出し"""
        try:
            # コンテキストを含むプロンプトの構築
            full_prompt = system_prompt + "\n\n" if system_prompt else ""
            if self.context:
                full_prompt += "前回の会話:\n"
                for ctx in self.context[-3:]:  # 最新3つ
                    full_prompt += f"{ctx['role']}: {ctx['content'][:200]}...\n"
                full_prompt += "\n"
            full_prompt += f"ユーザー: {prompt}"
            
            response = requests.post(
                f"{OLLAMA_URL}/api/generate",
                json={
                    "model": self.model,
                    "prompt": full_prompt,
                    "stream": False,
                    "options": {
                        "temperature": self.config.get("temperature", 0.7),
                        "num_predict": self.config.get("max_tokens", 4000)
                    }
                }
            )
            
            if response.status_code == 200:
                return response.json()["response"]
            else:
                return f"エラー: {response.status_code}"
        except Exception as e:
            return f"Ollama接続エラー: {e}"
    
    def process_command(self, user_input: str):
        """自然言語コマンドの処理"""
        self.print_colored(f"\n💭 考え中... ({self.model})", Colors.GRAY)
        
        # プロジェクト構造を取得
        project_info = f"プロジェクト構造:\n{self.get_project_structure()}"
        
        # システムプロンプト
        system_prompt = f"""あなたはOllama Codeアシスタントです。
ユーザーの指示に従って以下の操作を実行できます:
- ファイルの読み書き
- コマンドの実行
- Git操作
- コード検索
- エラー修正

現在のディレクトリ: {self.project_root}
{project_info}

以下の形式で応答してください:
1. タスクの理解を示す
2. 実行する操作を説明
3. 必要なコマンドを {{COMMAND:コマンド}} 形式で示す
4. ファイル編集は {{FILE:ファイル名}} と {{CONTENT:内容}} で示す
5. 結果の説明
"""
        
        # LLMに問い合わせ
        response = self.call_ollama(user_input, system_prompt)
        
        # 履歴に記録
        self.context.append({"role": "user", "content": user_input})
        self.context.append({"role": "assistant", "content": response})
        
        # ログ記録
        self.log_history({
            "timestamp": datetime.now().isoformat(),
            "conversation_id": self.conversation_id,
            "user": user_input,
            "assistant": response[:500],
            "model": self.model
        })
        
        # 応答の解析と実行
        self.execute_response(response)
    
    def execute_response(self, response: str):
        """LLMの応答を解析して実行"""
        self.print_colored("\n🤖 アシスタント:", Colors.BLUE)
        
        lines = response.split('\n')
        in_code_block = False
        code_content = []
        
        for line in lines:
            # コマンド実行
            if "{COMMAND:" in line:
                cmd = re.search(r'\{COMMAND:(.+?)\}', line)
                if cmd:
                    command = cmd.group(1).strip()
                    self.print_colored(f"\n$ {command}", Colors.YELLOW)
                    success, output = self.run_command(command)
                    if output:
                        print(output[:500])  # 最大500文字
                    continue
            
            # ファイル操作
            if "{FILE:" in line:
                file_match = re.search(r'\{FILE:(.+?)\}', line)
                if file_match:
                    filename = file_match.group(1).strip()
                    self.print_colored(f"\n📝 ファイル編集: {filename}", Colors.YELLOW)
                    continue
            
            # コンテンツブロック
            if "{CONTENT:" in line:
                in_code_block = True
                code_content = []
                continue
            elif in_code_block and "}" in line:
                in_code_block = False
                content = '\n'.join(code_content)
                # 最後に処理したファイル名を使用
                if 'filename' in locals():
                    self.write_file(filename, content)
                continue
            
            if in_code_block:
                code_content.append(line)
            else:
                print(line)
    
    def interactive_mode(self):
        """対話モード"""
        self.print_colored(f"""
╭─────────────────────────────────────╮
│  Ollama Code CLI - v1.0.0          │
│  Model: {self.model:<26} │
│  Type 'help' for commands          │
╰─────────────────────────────────────╯
""", Colors.BOLD)
        
        while True:
            try:
                user_input = input(f"\n{Colors.GREEN}ocode>{Colors.END} ").strip()
                
                if not user_input:
                    continue
                
                # 特殊コマンド
                if user_input.lower() in ['exit', 'quit', 'q']:
                    self.print_colored("\n👋 終了します", Colors.GRAY)
                    break
                elif user_input.lower() == 'help':
                    self.show_help()
                elif user_input.lower() == 'clear':
                    os.system('clear' if os.name == 'posix' else 'cls')
                    self.context = []
                elif user_input.lower().startswith('model '):
                    new_model = user_input[6:].strip()
                    self.model = new_model
                    self.config['model'] = new_model
                    self.save_config()
                    self.print_colored(f"✓ モデルを変更: {new_model}", Colors.GREEN)
                else:
                    # 自然言語コマンドとして処理
                    self.process_command(user_input)
                    
            except KeyboardInterrupt:
                print()
                continue
            except Exception as e:
                self.print_colored(f"\nエラー: {e}", Colors.RED)
    
    def show_help(self):
        """ヘルプの表示"""
        help_text = """
使用可能なコマンド:
  help          - このヘルプを表示
  clear         - 会話履歴をクリア
  model <name>  - モデルを変更
  exit/quit     - 終了

自然言語での指示例:
  • "このプロジェクトの構造を教えて"
  • "main.pyのエラーを修正して"
  • "READMEを作成して"
  • "テストを実行して失敗したら修正"
  • "変更をgitでコミット"
"""
        self.print_colored(help_text, Colors.GRAY)

def main():
    parser = argparse.ArgumentParser(description="Ollama Code - ローカルLLMコーディングアシスタント")
    parser.add_argument("command", nargs="?", help="実行するコマンド")
    parser.add_argument("-m", "--model", help="使用するモデル")
    parser.add_argument("-t", "--temperature", type=float, help="Temperature設定")
    parser.add_argument("--tokens", type=int, help="最大トークン数")
    
    args = parser.parse_args()
    
    # Ollama Codeインスタンスの作成
    ocode = OllamaCode()
    
    # オプションの適用
    if args.model:
        ocode.model = args.model
        ocode.config['model'] = args.model
    if args.temperature:
        ocode.config['temperature'] = args.temperature
    if args.tokens:
        ocode.config['max_tokens'] = args.tokens
    
    # コマンドがあれば実行、なければ対話モード
    if args.command:
        ocode.process_command(args.command)
    else:
        ocode.interactive_mode()

if __name__ == "__main__":
    main()