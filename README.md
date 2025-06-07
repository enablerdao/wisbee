# Ollama LLM ベンチマークツール & Wisbee チャットアプリ

Ollama言語モデルの性能測定とQ&A評価を行うツールキット、および完全プライベートなAIチャットアプリケーション。

## 🚀 Wisbee - AIとの対話を、もっと自然に

完全プライベートなAIチャットアプリ。あなたのデバイスで動く、高性能なローカルLLMチャットアプリケーション。

![Wisbee](https://img.shields.io/badge/Wisbee-AI%20Chat-7c3aed?style=for-the-badge&logo=ai&logoColor=white)

### ✨ 特徴

- 🚀 **ワンクリックセットアップ** - Ollamaもモデルも全て自動インストール
- 🎨 **美しいダークテーマ** - 目に優しいモダンなインターフェース
- 💬 **リアルタイムストリーミング** - 応答をリアルタイムで確認
- 🎯 **複数モデル対応** - 用途に応じてモデルを簡単切り替え
- ⚙️ **カスタマイズ可能** - トークン数、温度設定などを調整
- 🌸 **日本語完全対応** - UIから応答まで完全日本語対応
- 🔒 **完全プライベート** - データは全てローカル処理、外部送信なし
- 🎙️ **音声チャット対応** - リアルタイム音声入力・出力

### 🚀 クイックスタート

#### Mac版アプリ（推奨）

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

#### Web版（手動セットアップ）

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

## 📊 ベンチマークツール

### 概要

このプロジェクトは、Ollamaで動作する各種言語モデルの性能を多角的に評価するための統合ベンチマークツールです。

### 主要コンポーネント

- **obench.sh** - シンプルな性能測定（トークン/秒）
- **obench2.sh** - 包括的なQ&A評価（GPT-4採点オプション付き）
- **questions.txt** - 15問の日本語評価問題セット

### インストール

```bash
# 依存関係のインストール
brew install jq bc

# Ollamaのインストール（未インストールの場合）
brew install ollama
```

### 使用方法

#### 性能ベンチマーク

```bash
# デフォルトモデルをテスト
./obench.sh

# 特定モデルをテスト
./obench.sh gemma2:2b llama3:latest

# カスタムトークン上限でテスト
./obench.sh --max-tok 2048
```

#### Q&A評価

```bash
# GPT-4採点付きQ&A評価
export OPENAI_API_KEY="your-key-here"
./obench2.sh

# 採点なしで実行
./obench2.sh --no-score

# 特定モデルをカスタムトークン上限でテスト
./obench2.sh gemma3:1b qwen3:latest --max-tok 128
```

## 📈 ベンチマーク結果（2025年6月6日）

### モデル評価サマリー

| モデル | サイズ | 総合評価 | 速度 | 精度 | 日本語 | 特徴 |
|--------|--------|----------|------|------|---------|------|
| **gemma3:4b** | 3.3GB | ⭐⭐⭐⭐ | 中速 | 高 | 良好 | バランス最良 |
| **qwen3:latest** | 5.2GB | ⭐⭐⭐⭐ | 遅い | 高 | 優秀 | 思考プロセス付き |
| **phi3:mini** | 2.2GB | ⭐⭐⭐ | 高速 | 中 | 可 | コスパ良好 |
| **llama3.2:1b** | 1.3GB | ⭐⭐ | 高速 | 低 | 可 | 軽量・高速 |
| **qwen3:1.7b** | 1.4GB | ⭐⭐⭐ | 中速 | 中 | 良好 | 小型で高性能 |

### 📝 使い分けガイド
- **高精度が必要**: qwen3:latest または gemma3:4b
- **速度重視**: phi3:mini または llama3.2:1b
- **日本語重視**: qwen3系列
- **バランス重視**: gemma3:4b

## 🎙️ リアルタイム音声チャット機能

### 概要
音声入力・音声出力に対応したリアルタイムチャットインターフェースを実装しました。

### 機能
- **リアルタイム音声認識**: Web Speech APIによる高速な音声認識
- **自然な音声合成**: Edge TTSとgTTSによる高品質な音声出力
- **ストリーミング応答**: AIの応答を逐次的に音声化
- **連続会話モード**: ハンズフリーでの対話が可能
- **ビジュアルフィードバック**: 音声レベルメーターとアニメーション

### 使用方法

```bash
# 依存関係のインストール
pip3 install -r requirements-voice.txt

# 音声チャットの起動
./start-voice-chat.sh
```

ブラウザで `http://localhost:8890/realtime-voice-chat.html` を開きます。

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

## 📁 プロジェクト構成

```
bench-llm/
├── obench.sh              # 性能ベンチマーク
├── obench2.sh             # Q&A評価ツール
├── questions.txt          # 評価用質問セット
├── CLAUDE.md              # プロジェクト指示書
├── config.json            # 設定ファイル
├── ollama-webui-server.py # Pythonサーバー
├── index.html             # メインUI
├── wisbee-mac/           # macOS向けElectronアプリ
├── wisbee-ios/           # iOS向けチャットアプリ
└── ollama-code-cli/      # CLIベースのコード支援ツール
```

## 🤝 コントリビューション

プルリクエスト大歓迎です！

1. リポジトリをフォーク
2. フィーチャーブランチを作成 (`git checkout -b feature/amazing-feature`)
3. 変更をコミット (`git commit -m 'Add some amazing feature'`)
4. ブランチにプッシュ (`git push origin feature/amazing-feature`)
5. プルリクエストを作成

## 📄 ライセンス

このプロジェクトはMITライセンスで公開されています。詳細は[LICENSE](LICENSE)を参照

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