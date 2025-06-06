# Ollama Chat iOS App

iPhoneでローカルLLMを実行し、Mac上のOllamaモデルにも接続できるチャットアプリです。

## 機能

- 📱 **ローカルモデル実行** - iPhone上でqwen3-abliterated:0.6bを実行
- 🖥️ **Mac接続** - Mac上のOllamaサーバーに接続して他のモデルを使用
- 💬 **リアルタイムチャット** - 美しいネイティブUIでスムーズな会話
- 🌐 **オフライン対応** - インターネット接続不要でローカルモデルを使用

## セットアップ

### 1. 開発環境の準備

```bash
# Xcodeをインストール（App Storeから）
# iOS 16.0以上のデバイスまたはシミュレーター
```

### 2. モデルの準備

#### オプション1: CoreMLモデル（推奨）
```bash
# Python環境でモデルを変換
pip install coremltools transformers

python convert_to_coreml.py
```

#### オプション2: llama.cppの使用
```bash
# llama.cppをiOS用にビルド
git clone https://github.com/ggerganov/llama.cpp
cd llama.cpp
make ios
```

### 3. プロジェクトのビルド

1. Xcodeで`OllamaChat.xcodeproj`を開く
2. ターゲットデバイスを選択
3. `Cmd + R`でビルド・実行

## 使い方

### ローカルモデルの使用
1. アプリを起動
2. 右上のモデル選択で「local」を選択
3. メッセージを入力して送信

### Mac接続の設定
1. MacでOllamaを起動
```bash
ollama serve
```

2. iPhoneアプリの設定画面でMacのIPアドレスを入力
3. モデル選択でMac上のモデルを選択

## 技術仕様

- **フレームワーク**: SwiftUI, Combine
- **モデル形式**: CoreML または GGUF (llama.cpp)
- **最小iOS**: iOS 16.0
- **対応デバイス**: iPhone, iPad

## トラブルシューティング

### モデルが読み込めない
- モデルファイルがアプリバンドルに含まれているか確認
- デバイスのストレージ容量を確認

### Mac接続ができない
- 同じWi-Fiネットワークに接続されているか確認
- MacのファイアウォールでOllamaのポート(11434)が開いているか確認

## 今後の改善予定

- [ ] より多くのローカルモデルのサポート
- [ ] ストリーミングレスポンス
- [ ] 会話履歴の保存
- [ ] モデルのダウンロード機能
- [ ] Metal Performance Shadersを使用した高速化