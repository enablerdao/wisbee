# Ollama Code CLI

Claude Code風のローカルLLMコーディングアシスタント

## 🚀 特徴

- **自然言語でコーディング**: 日本語で指示するだけ
- **マルチファイル編集**: 複数ファイルを一度に編集
- **自動エラー修正**: エラーを検出して自動修正
- **Git統合**: コミット、ブランチ操作を自動化
- **プライバシー重視**: 完全ローカル実行

## 📦 インストール

```bash
git clone https://github.com/yourusername/ollama-code-cli.git
cd ollama-code-cli
./setup.sh
```

## 🎯 使い方

### 対話モード
```bash
ocode
```

### ワンショット実行
```bash
ocode "READMEを日本語で作成して"
ocode "main.pyのバグを修正"
ocode "テストを実行して失敗したら修正"
```

### モデル指定
```bash
ocode -m qwen3:1.7b "コードをリファクタリング"
```

## 💡 コマンド例

```bash
# プロジェクト構造の確認
ocode "このプロジェクトの構造を教えて"

# ファイル作成・編集
ocode "設定ファイルconfig.jsonを作成"
ocode "server.pyにログ機能を追加"

# エラー修正
ocode "Pythonのエラーをすべて修正"
ocode "型チェックエラーを解決"

# テスト
ocode "テストを実行して結果を教えて"
ocode "失敗したテストを修正"

# Git操作
ocode "変更をコミット"
ocode "新しいブランチを作成"
```

## ⚙️ 設定

`~/.ocode/config.json`:
```json
{
  "model": "qwen3:1.7b",
  "max_tokens": 4000,
  "temperature": 0.7,
  "thinking_mode": "balanced"
}
```

## 🛠 対応機能

- ✅ 自然言語指示受付
- ✅ コードベース理解
- ✅ マルチファイル編集
- ✅ 自動エラー修正
- ✅ テスト実行＆修正
- ✅ Git操作統合
- ✅ コード検索
- ✅ 実行履歴管理
- ✅ 設定カスタマイズ

## 📝 ライセンス

MIT License