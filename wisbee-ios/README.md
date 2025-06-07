# Wisbee - iOS Local LLM Chat App

美しいUIでローカルLLMとチャットできるiOSアプリ。iPhone上でqwen3-abliterated:0.6bを実行し、Mac接続時は他の高性能モデルも使用可能。

![Wisbee](https://img.shields.io/badge/Wisbee-AI%20Chat-purple?style=for-the-badge&logo=sparkles&logoColor=white)

## ✨ 特徴

- 🎨 **美しいダークUI** - グラデーションとアニメーションを使用したモダンなデザイン
- 📱 **完全ローカル実行** - インターネット接続不要でプライバシー保護
- 🚀 **高速レスポンス** - llama.cppによる最適化された推論
- 🔄 **Mac連携** - Ollamaサーバーと接続して高性能モデルを使用
- 💬 **日本語対応** - 日本語での自然な会話が可能

## 📲 インストール方法

### 方法1: Xcodeでビルド

1. **リポジトリをクローン**
```bash
git clone https://github.com/enablerdao/wisbee-ios.git
cd wisbee-ios
```

2. **Xcodeでプロジェクトを開く**
```bash
open Wisbee.xcodeproj
```

3. **依存関係をインストール**
   - Xcode > File > Add Package Dependencies
   - `https://github.com/StanfordSpezi/SpeziLLM` を追加

4. **ビルドして実行**
   - デバイスまたはシミュレーターを選択
   - `Cmd + R` で実行

### 方法2: TestFlightでインストール（準備中）

## 🛠️ 技術仕様

### 使用技術
- **言語**: Swift 5.9+
- **UI**: SwiftUI
- **LLM**: llama.cpp (SpeziLLM経由)
- **モデル**: qwen3-abliterated 0.6B (GGUF形式)
- **最小iOS**: iOS 16.0

### アーキテクチャ
```
Wisbee/
├── WisbeeApp.swift          # アプリエントリーポイント
├── Views/
│   └── ContentView.swift    # メインUI
├── ViewModels/
│   └── ChatViewModel.swift  # ビジネスロジック
├── Models/
│   └── ChatMessage.swift    # データモデル
└── Services/
    └── LLMRunner.swift      # LLM実行サービス
```

## 🎮 使い方

### ローカルモード
1. アプリを起動
2. 自動的にローカルモデルが読み込まれます
3. メッセージを入力して送信

### Mac連携モード
1. MacでOllamaを起動
```bash
ollama serve
```

2. アプリの設定でMacのIPアドレスを入力
3. より高性能なモデルが使用可能に

## 🔧 カスタマイズ

### モデルの変更
`ChatViewModel.swift`の`modelURL`を変更：
```swift
private let modelURL = "https://huggingface.co/your-model.gguf"
```

### UIテーマの変更
`ContentView.swift`のカラー定義を編集

## 🐛 トラブルシューティング

### モデルが読み込めない
- デバイスのストレージ容量を確認
- ネットワーク接続を確認（初回ダウンロード時）

### パフォーマンスが遅い
- Settings > Wisbee > Model Quality で品質を調整
- バックグラウンドアプリを終了

## 🚀 今後の予定

- [ ] 複数モデルのローカル保存
- [ ] 会話履歴の保存と検索
- [ ] 画像生成機能
- [ ] Apple Watch対応
- [ ] ウィジェット対応

## 📄 ライセンス

MIT License - 詳細は[LICENSE](LICENSE)を参照

## 🤝 貢献

プルリクエスト歓迎！大きな変更の場合は、まずissueを作成してください。

---

Made with 💜 by [EnablerDAO](https://github.com/enablerdao)