# Ollama Chat for Mac - インストールガイド

## 📥 ダウンロード

お使いのMacに合わせて適切なバージョンをダウンロードしてください：

- **Intel Mac**: [Ollama Chat-1.0.0.dmg](dist/Ollama%20Chat-1.0.0.dmg)
- **Apple Silicon (M1/M2/M3)**: [Ollama Chat-1.0.0-arm64.dmg](dist/Ollama%20Chat-1.0.0-arm64.dmg)

## 🚀 インストール手順

### 1. 事前準備

Ollamaがインストールされていることを確認してください：

```bash
# Ollamaのインストール（まだの場合）
curl -fsSL https://ollama.ai/install.sh | sh

# Ollamaを起動
ollama serve

# モデルをダウンロード（例：qwen3）
ollama pull qwen3:1.7b
```

### 2. アプリのインストール

1. ダウンロードしたDMGファイルをダブルクリック
2. 開いたウィンドウで「Ollama Chat」を「Applications」フォルダにドラッグ

### 3. 初回起動（重要）

**セキュリティ警告の回避方法：**

このアプリは現在Apple Developer IDで署名されていないため、初回起動時に警告が表示されます。

1. Finderで「アプリケーション」フォルダを開く
2. 「Ollama Chat」を**右クリック**（またはControlキーを押しながらクリック）
3. メニューから「開く」を選択
4. 警告ダイアログで「開く」をクリック

![初回起動の手順](https://user-images.githubusercontent.com/xxx/xxx.png)

### 4. 通常の起動

初回起動後は、通常通りLaunchpadやアプリケーションフォルダから起動できます。

## 🔧 トラブルシューティング

### 「開発元が未確認」エラーが出る場合

上記の手順3を必ず実行してください。それでも開けない場合：

1. システム環境設定 → セキュリティとプライバシー
2. 「一般」タブ
3. 「このまま開く」ボタンをクリック

### Ollamaに接続できない場合

1. Ollamaが起動しているか確認：
   ```bash
   curl http://localhost:11434/api/tags
   ```

2. モデルがインストールされているか確認：
   ```bash
   ollama list
   ```

3. ファイアウォールがポート11434をブロックしていないか確認

### アプリが起動しない場合

1. macOSのバージョンが10.12以降であることを確認
2. ログを確認：
   ```bash
   open ~/Library/Logs/Ollama\ Chat/
   ```

## 📱 使い方

1. アプリを起動
2. 上部のドロップダウンからモデルを選択
3. メッセージを入力して送信
4. リアルタイムで応答を確認

### ショートカットキー

- `Cmd+K`: チャットをクリア
- `Cmd+,`: 設定を開く
- `Cmd+Enter`: メッセージ送信

## 🆘 サポート

問題が解決しない場合：

- [GitHub Issues](https://github.com/enablerdao/ollama-chat-ui/issues)で報告
- [Discord](https://discord.gg/enablerdao)でコミュニティに質問

## 🔒 セキュリティについて

このアプリは現在署名されていませんが、オープンソースであり、ソースコードは[GitHub](https://github.com/enablerdao/ollama-chat-ui)で確認できます。

将来的にApple Developer IDを取得し、公証済みバージョンをリリース予定です。