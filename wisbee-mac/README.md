# Wisbee - AIとの対話を、もっと自然に

<p align="center">
  <img src="assets/icon.png" width="120" height="120" alt="Wisbee Logo">
</p>

<p align="center">
  <strong>完全プライベートなAIチャットアプリ for Mac</strong><br>
  あなたのMacで動く、高性能なローカルLLMチャットアプリケーション
</p>

<p align="center">
  <a href="#-ダウンロード">ダウンロード</a> •
  <a href="#-特徴">特徴</a> •
  <a href="#-インストール">インストール</a> •
  <a href="#-使い方">使い方</a> •
  <a href="#-よくある質問">FAQ</a>
</p>

---

## 📥 ダウンロード

<table>
  <tr>
    <th>プロセッサ</th>
    <th>ダウンロード</th>
    <th>サイズ</th>
    <th>対応Mac</th>
  </tr>
  <tr>
    <td><strong>Apple Silicon</strong></td>
    <td><a href="https://github.com/enablerdao/wisbee/releases/download/v1.0.0/Wisbee-1.0.0-arm64.dmg">Wisbee-1.0.0-arm64.dmg</a></td>
    <td>94.1 MB</td>
    <td>M1, M2, M3 Mac</td>
  </tr>
  <tr>
    <td><strong>Intel</strong></td>
    <td><a href="https://github.com/enablerdao/wisbee/releases/download/v1.0.0/Wisbee-1.0.0.dmg">Wisbee-1.0.0.dmg</a></td>
    <td>100.6 MB</td>
    <td>Intel Mac</td>
  </tr>
</table>

**システム要件**: macOS 10.12 以降

## ✨ 特徴

### 🚀 簡単セットアップ
- **ワンクリックインストール**: 技術的な知識は一切不要
- **自動セットアップ**: Ollamaとモデルを自動でインストール
- **即座に利用開始**: セットアップ完了後、すぐに使える

### 🔒 完全プライベート
- **100%ローカル処理**: すべてのデータはあなたのMac内で処理
- **インターネット不要**: 初回セットアップ後はオフラインで動作
- **データ収集なし**: 会話履歴や個人情報は一切外部に送信されません

### ⚡ 高性能
- **リアルタイムストリーミング**: 応答を逐次表示
- **複数モデル対応**: 用途に応じてモデルを切り替え可能
- **高速レスポンス**: 最適化されたローカル処理

### 🎨 美しいインターフェース
- **macOSネイティブ**: システムと完全に統合
- **ダークモード対応**: 目に優しい設計
- **日本語完全対応**: UIから応答まですべて日本語

## 📦 インストール

### ステップ 1: ダウンロード
1. 上記の表から、お使いのMacに合ったバージョンをダウンロード
2. ダウンロードしたDMGファイルをダブルクリック

### ステップ 2: インストール
1. 開いたウィンドウで「Wisbee」を「Applications」フォルダにドラッグ
2. DMGウィンドウを閉じる

### ステップ 3: 初回起動
**重要**: 署名されていないアプリのため、以下の手順で起動してください：

1. Finderで「アプリケーション」フォルダを開く
2. 「Wisbee」を**右クリック**（またはControlキーを押しながらクリック）
3. メニューから「開く」を選択
4. 警告ダイアログで「開く」をクリック

<details>
<summary>🖼️ 画像で確認</summary>

![右クリックして開く](assets/open-instruction.png)

</details>

### ステップ 4: 自動セットアップ
初回起動時に自動セットアップウィザードが表示されます：

1. **「開始する」をクリック**
2. **Ollamaの自動インストール**（約1分）
3. **モデルの選択とダウンロード**（2-5分）
   - 推奨: qwen3:1.7b（高速・日本語対応）
4. **セットアップ完了！**

## 🎯 使い方

### 🚀 確実な起動方法

**推奨**: 専用の起動スクリプトを使用（ポート競合を自動解決）
```bash
cd /Users/yuki/bench-llm/wisbee-mac
./start-wisbee.sh
```

**手動起動**:
```bash
cd /Users/yuki/bench-llm/wisbee-mac
# 既存プロセスの停止
pkill -f electron; pkill -f ollama-webui-server; lsof -ti:8899 | xargs kill -9
# アプリ起動
npm start
```

### アプリへのアクセス
- **固定ポート**: `8899` （競合しないよう調整済み）
- **メインチャット**: http://localhost:8899
- **ダウンロードページ**: http://localhost:8899/download

### 新機能
- 🐝 美しいWisbeeデザイン - アニメーション効果付きの洗練されたUI
- ChatGPTより安全・無料・オープンなAI
- グラデーション効果とホバーアニメーション
- 日本語に最適化されたインターフェース

### ⚠️ 起動時の注意点
1. **ポート8899**が他のアプリで使用されていないか確認
2. **Ollama**（ポート11434）が事前に起動していることを確認
3. 起動に失敗する場合は`start-wisbee.sh`を使用

### 基本的な使い方
1. テキストボックスにメッセージを入力
2. EnterキーまたはSendボタンで送信
3. AIからの応答をリアルタイムで確認

### モデルの切り替え
- 上部のドロップダウンメニューからモデルを選択
- 各モデルの特徴：
  - **qwen3:1.7b**: 高速・日本語対応（推奨）
  - **llama3.2:1b**: バランス型
  - **gemma2:2b**: 高品質な応答

### パラメーター調整
- **Max Tokens**: 応答の最大長（10-8000）
- **Temperature**: 創造性の調整（0.0-2.0）
  - 低い値: より正確で一貫性のある応答
  - 高い値: より創造的で多様な応答

### ショートカットキー
| キー | 機能 |
|------|------|
| `Cmd + K` | チャットをクリア |
| `Cmd + ,` | 設定を開く |
| `Cmd + Enter` | メッセージ送信 |
| `Cmd + R` | 画面をリロード |

## ❓ よくある質問

<details>
<summary><strong>Q: 初回起動時に「開発元が未確認」というエラーが出ます</strong></summary>

A: これは正常です。上記の「初回起動」の手順に従って、右クリックから開いてください。
</details>

<details>
<summary><strong>Q: Ollamaがインストールできません</strong></summary>

A: 以下を確認してください：
- インターネット接続が安定している
- macOSのバージョンが10.12以降
- 十分なディスク容量がある（最低10GB推奨）
</details>

<details>
<summary><strong>Q: モデルのダウンロードが遅い</strong></summary>

A: モデルのサイズは1-2GBあるため、インターネット速度により時間がかかる場合があります。安定した接続環境でお試しください。
</details>

<details>
<summary><strong>Q: オフラインで使えますか？</strong></summary>

A: はい！初回セットアップ完了後は、完全にオフラインで使用できます。
</details>

<details>
<summary><strong>Q: 会話データはどこに保存されますか？</strong></summary>

A: すべてのデータはローカルに保存され、外部には一切送信されません。アプリを削除すると、すべてのデータも削除されます。
</details>

## 🛠️ トラブルシューティング

### アプリが起動しない
```bash
# ターミナルで以下を実行
xattr -cr /Applications/Wisbee.app
```

### Ollamaサーバーに接続できない
```bash
# Ollamaが起動しているか確認
curl http://localhost:11434/api/tags

# 手動でOllamaを起動
ollama serve
```

### ログの確認
```bash
# アプリケーションログ
~/Library/Logs/Wisbee/

# Ollamaログ
~/.ollama/logs/
```

## 🤖 自動化とCI/CD

Wisbeeは完全自動化されたテストとデプロイメントパイプラインを備えています：

### 🔄 GitHub Actions CI/CD
- **自動テスト**: すべてのPRで品質チェック、ユニットテスト、E2Eテストを実行
- **クロスプラットフォームビルド**: Windows、macOS、Linux用バイナリを自動生成
- **自動リリース**: タグプッシュで自動的にGitHub Releasesにデプロイ
- **パフォーマンス監視**: 応答速度とメモリ使用量を継続的に監視

### 🧪 テストスイート
```bash
# 全テスト実行
npm test

# E2Eテスト（Playwright）
npm run test:e2e

# パフォーマンステスト
npm run test:performance

# コードカバレッジ
npm run test:coverage
```

### 📊 品質チェック
```bash
# ESLint
npm run lint

# Prettier
npm run format

# セキュリティ監査
npm audit
```

### 🚀 自動デプロイ
1. コードをmainブランチにプッシュ
2. 自動テストが全て成功
3. タグを作成すると自動的にリリース
4. バイナリファイルがGitHub Releasesに公開

## 🤝 コントリビューション

Wisbeeはオープンソースプロジェクトです。改善提案やバグ報告は大歓迎です！

### 開発環境のセットアップ
```bash
git clone https://github.com/enablerdao/wisbee.git
cd wisbee/wisbee-mac
npm install
npm start
```

### プルリクエストの流れ
1. フォークして機能ブランチを作成
2. 変更を実装（自動テストが通ることを確認）
3. プルリクエストを作成
4. 自動的にCI/CDパイプラインが実行
5. すべてのチェックが通過後、自動マージ（依存関係更新の場合）

- **バグ報告**: [Issues](https://github.com/enablerdao/wisbee/issues)
- **機能リクエスト**: [Discussions](https://github.com/enablerdao/wisbee/discussions)
- **プルリクエスト**: [Contributing Guide](CONTRIBUTING.md)

## 📄 ライセンス

MIT License - 詳細は[LICENSE](LICENSE)ファイルを参照してください。

## 🙏 謝辞

- [Ollama](https://ollama.ai/) - 素晴らしいローカルLLMランタイム
- オープンソースモデルの開発者の皆様
- フィードバックをくださったユーザーの皆様

---

<p align="center">
  Made with ❤️ by <a href="https://github.com/enablerdao">EnablerDAO</a>
</p>