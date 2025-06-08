# Wisbee - App Store 配布情報

## 📱 アプリ情報

**アプリ名**: Wisbee - AI Chat for Ollama
**カテゴリ**: 開発ツール / 仕事効率化
**価格**: 無料

## 📝 App Store説明文

### 日本語

**Wisbee - ローカルAIチャットの決定版**

Wisbeeは、Ollamaで動作するAIモデルと美しく対話できるmacOSアプリです。プライバシーを重視し、すべての処理をローカルで実行します。

**主な機能:**
• 美しいMarkdownレンダリング
• シンタックスハイライト付きコードブロック
• AIの思考プロセスを可視化する<think>タグ対応
• 複数のAIモデルを簡単に切り替え
• 日本語完全対応
• ダークモード対応の洗練されたUI

**特徴:**
• 完全オフライン動作（インターネット不要）
• プライバシー保護（データは外部送信されません）
• 高速レスポンス
• 無料・無制限

**必要環境:**
• macOS 10.15以降
• Ollama（https://ollama.ai）のインストールが必要

### English

**Wisbee - Beautiful AI Chat for Ollama**

Wisbee is a beautifully designed macOS app for chatting with AI models running on Ollama. Privacy-focused with all processing done locally.

**Key Features:**
• Beautiful Markdown rendering
• Syntax-highlighted code blocks
• <think> tag visualization for AI reasoning
• Easy model switching
• Full Japanese support
• Elegant dark mode UI

**Benefits:**
• Completely offline (no internet required)
• Privacy protected (no data sent externally)
• Fast response times
• Free & unlimited

**Requirements:**
• macOS 10.15 or later
• Ollama (https://ollama.ai) must be installed

## 🔒 プライバシーポリシー

Wisbeeは、ユーザーのプライバシーを最優先に考えています。

1. **データ収集なし**: Wisbeeは個人情報を一切収集しません
2. **ローカル処理**: すべてのAI処理はお使いのMac上で実行されます
3. **外部送信なし**: チャット内容や使用状況は外部に送信されません
4. **広告なし**: 広告やトラッキングは一切ありません

## 📋 App Store提出に必要なもの

### 1. Apple Developer Program
- 年間$99の開発者登録が必要
- https://developer.apple.com/programs/

### 2. 必要な証明書
- Mac App Distribution Certificate
- Mac Installer Distribution Certificate
- App Store Provisioning Profile

### 3. App Store Connect設定
```
Bundle ID: com.wisbee.chat
SKU: WISBEE001
```

### 4. スクリーンショット
必要なサイズ:
- 1280 x 800 (必須)
- 1440 x 900 (必須)
- 2560 x 1600 (Retina)
- 2880 x 1800 (Retina)

### 5. アプリアイコン
- 1024 x 1024 (App Store用)
- 512 x 512 (Retina)
- 256 x 256
- 128 x 128
- 64 x 64
- 32 x 32
- 16 x 16

## 🚀 提出プロセス

1. **Xcodeでアーカイブ作成**
   ```bash
   xcodebuild archive -scheme Wisbee -archivePath ./build/Wisbee.xcarchive
   ```

2. **App Store Connect Upload**
   - Xcode Organizer使用
   - または `xcrun altool`

3. **審査提出**
   - App Store Connectで情報入力
   - スクリーンショットアップロード
   - 審査提出

## 📌 審査対策

### 重要ポイント:
1. **Ollamaの説明**: 初回起動時にOllamaのインストールを案内
2. **オフライン動作**: ネットワーク権限は localhost のみ
3. **コンテンツ**: AIの出力内容に対する免責事項を追加
4. **年齢制限**: 4+ (教育カテゴリ)

### 追加が必要な機能:
- 初回起動時のチュートリアル
- Ollamaインストールチェック＆案内
- ヘルプドキュメント
- サポート連絡先

## 💰 収益化オプション

1. **無料 + Pro版**
   - 基本機能: 無料
   - Pro機能: 月額 ¥480
     - 無制限の会話履歴
     - カスタムプロンプト保存
     - エクスポート機能

2. **買い切り**
   - ¥1,220 (一度購入で永久利用)

3. **完全無料**
   - 広告なし
   - オープンソースとして公開