# App Store 提出手順

## 🔐 証明書の設定

1. **Xcodeで証明書を作成**
   - Xcode → Preferences → Accounts
   - Apple IDでサインイン
   - Manage Certificates → 「+」
   - "Mac App Distribution" と "Mac Installer Distribution" を作成

2. **プロビジョニングプロファイル作成**
   - https://developer.apple.com/account/
   - Certificates, Identifiers & Profiles
   - Profiles → 「+」
   - "Mac App Store" を選択
   - App ID: com.wisbee.chat (まだない場合は先に作成)

## 📦 ビルドコマンド

```bash
# 1. クリーンビルド
rm -rf dist/

# 2. App Store用ビルド（要証明書）
npm run dist-mas

# または環境変数で証明書を指定
CSC_LINK=/path/to/certificate.p12 \
CSC_KEY_PASSWORD=your_password \
npm run dist-mas
```

## 🚀 App Store Connect提出

1. **App Store Connectでアプリ作成**
   - https://appstoreconnect.apple.com/
   - My Apps → 「+」 → 新規App
   - プラットフォーム: macOS
   - 名前: Wisbee - AI Chat for Ollama
   - プライマリ言語: 日本語
   - バンドルID: com.wisbee.chat
   - SKU: WISBEE001

2. **Transporter使用**
   ```bash
   # Transporterをインストール
   # App Storeから「Transporter」をダウンロード
   
   # または xcrun altool
   xcrun altool --upload-app -f dist/mas/Wisbee-1.0.0.pkg \
                -t macos \
                -u your@email.com \
                -p app-specific-password
   ```

## 📋 審査情報

### アプリ説明
```
Wisbeeは、Ollamaで動作するAIモデルと美しく対話できるmacOSアプリです。
プライバシーを重視し、すべての処理をローカルで実行します。

主な機能:
• 美しいMarkdownレンダリング
• シンタックスハイライト付きコードブロック
• AIの思考プロセスを可視化
• 複数のAIモデルを簡単に切り替え
• 完全オフライン動作
```

### 審査メモ
```
このアプリはOllama (https://ollama.ai) のインストールが必要です。
Ollamaは無料のオープンソースソフトウェアです。
アプリ自体はOllamaのフロントエンドとして機能します。

テスト手順:
1. Ollamaをインストール (https://ollama.ai)
2. ターミナルで: ollama pull llama3.2:1b
3. Wisbeeを起動
4. チャットを開始
```

### レビューに必要な情報
- デモアカウント: 不要
- 特別な設定: Ollamaのインストールが必要
- 年齢制限: 4+

## ⚠️ 注意事項

1. **Sandboxの制限**
   - App Store版はSandbox内で動作
   - localhost:11434 への接続に制限あり
   - 回避策: XPC Service または App Group使用

2. **Pythonサーバー問題**
   - App Store版ではPythonスクリプトの実行が難しい
   - 解決策: Node.jsでサーバーを書き直す

3. **審査での指摘可能性**
   - 外部ソフトウェア（Ollama）依存
   - → 明確な説明とインストールガイドを提供
   - ローカルサーバーへの接続
   - → セキュリティとプライバシーの利点を強調