# Wisbee - AIとの対話を、もっと自然に

完全プライベートなAIチャットアプリ。あなたのデバイスで動く、高性能なローカルLLMチャットアプリケーション。

![Wisbee](https://img.shields.io/badge/Wisbee-AI%20Chat-7c3aed?style=for-the-badge&logo=ai&logoColor=white)

## ✨ 特徴

- 🚀 **ワンクリックセットアップ** - Ollamaもモデルも全て自動インストール
- 🎨 **美しいダークテーマ** - 目に優しいモダンなインターフェース
- 💬 **リアルタイムストリーミング** - 応答をリアルタイムで確認
- 🎯 **複数モデル対応** - 用途に応じてモデルを簡単切り替え
- ⚙️ **カスタマイズ可能** - トークン数、温度設定などを調整
- 🌸 **日本語完全対応** - UIから応答まで完全日本語対応
- 🔒 **完全プライベート** - データは全てローカル処理、外部送信なし

## 🚀 クイックスタート

### Mac版アプリ（推奨）

**技術的な知識は不要！** アプリが全て自動でセットアップします。

1. **ダウンロード**
   - [Apple Silicon版 (M1/M2/M3)](https://github.com/enablerdao/wisbee/releases) 
   - [Intel Mac版](https://github.com/enablerdao/wisbee/releases)

2. **インストール**
   - DMGを開いてアプリをApplicationsフォルダにドラッグ
   - 初回起動時は右クリック→「開く」

3. **自動セットアップ**
   - アプリが自動でOllamaとモデルをインストール
   - 5分程度で完了！

### Web版（手動セットアップ）

#### 前提条件

1. [Ollama](https://ollama.ai/)をインストール
2. 使用するモデルをダウンロード：
```bash
ollama pull qwen3:1.7b
ollama pull llama3.2:1b
```

#### インストール

```bash
# リポジトリをクローン
git clone https://github.com/enablerdao/wisbee.git
cd wisbee

# 依存関係をインストール
pip install requests

# サーバーを起動
python3 ollama-webui-server.py
```

ブラウザで `http://localhost:8899` を開く

## ⚙️ 設定

`config.json`で以下をカスタマイズ可能：

```json
{
  "server": {
    "port": 8899,
    "host": "localhost"
  },
  "ollama": {
    "url": "http://localhost:11434",
    "defaultModel": "qwen3:latest",
    "models": [
      "qwen3:latest",
      "llama3.2:1b",
      "phi3:mini",
      "gemma3:4b",
      "gemma3:1b"
    ]
  },
  "ui": {
    "defaultMaxTokens": 2000,
    "defaultTemperature": 0.7,
    "theme": "dark",
    "title": "Ollama AI Chat"
  }
}
```

## 🎯 使い方

### 基本的なチャット
1. メッセージを入力
2. EnterキーまたはSendボタンをクリック
3. リアルタイムで応答を確認

### サンプルプロンプト
- サイドバーのプロンプトをクリックして使用
- カテゴリ：創造的、論理、数学、コード、日本語

### モデル切り替え
- ヘッダーのドロップダウンでモデルを選択
- 各モデルで性能と速度が異なります

### パラメータ調整
- **Max Tokens**: 応答の長さ (10-8000)
- **Temperature**: 創造性 (0.0-2.0)
  - 低い = より正確・一貫性
  - 高い = より創造的・多様

## 🛠️ カスタム設定

### 異なるポートで実行
```bash
python3 ollama-webui-server.py 8080
```

### カスタム設定ファイル
プロジェクトディレクトリに独自の`config.json`を作成

## 📁 プロジェクト構成

```
wisbee/
├── index.html              # メインUI
├── ollama-webui-server.py  # Pythonサーバー
├── config.json            # 設定ファイル
├── ollama-chat-mac/       # Macアプリ版
│   ├── main-enhanced.js   # 自動セットアップ機能
│   ├── setup-wizard.html  # セットアップウィザード
│   └── dist/             # ビルド済みアプリ
└── README.md             # このファイル
```

## 🤝 コントリビューション

プルリクエスト大歓迎です！

1. リポジトリをフォーク
2. フィーチャーブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add some amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 📄 ライセンス

MIT License - 詳細は[LICENSE](LICENSE)を参照

## 🙏 謝辞

- [Ollama](https://ollama.ai/) - 素晴らしいローカルLLMランタイム
- オープンソースモデルの開発者の皆様
- AIコミュニティの皆様

## ❓ よくある質問

**Q: Ollamaのインストール方法は？**  
A: Mac版アプリなら自動でインストールされます！手動の場合は[Ollama公式サイト](https://ollama.ai/)から。

**Q: どのモデルがおすすめ？**  
A: 日本語なら`qwen3:1.7b`、英語なら`llama3.2:1b`がバランスが良いです。

**Q: オフラインで使える？**  
A: はい！初回セットアップ後は完全オフラインで動作します。

## 📞 サポート

- [Issues](https://github.com/enablerdao/wisbee/issues)でバグ報告
- [Discussions](https://github.com/enablerdao/wisbee/discussions)で質問

---

Made with ❤️ by [EnablerDAO](https://github.com/enablerdao)