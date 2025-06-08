# Wisbee プラットフォーム戦略

## 🐝 ポート割り当て計画

### メインサービスポート（記憶しやすい番号）
- **8888** - Wisbee Web UI メインポート（BはBeeのB）
- **7777** - Voice/リアルタイム機能用
- **9999** - 開発/プレミアム機能用
- **8899** - 現在のデフォルト（フォールバック用）
- **11434** - Ollama API（変更不可）

## 📱 プラットフォーム別状況

### 1. **Web版** (/wisbee/)
- **状態**: 稼働中
- **ポート**: 8080 (start.sh) / 8899 (ollama-webui-server.py)
- **特徴**: ブラウザベースのOllama UI

### 2. **macOS版** (/wisbee-mac/)
- **状態**: リリース済み
- **形式**: Electron App（DMG配布）
- **サイズ**: 
  - Apple Silicon: 94.1MB
  - Intel: 100.6MB
- **特徴**: ネイティブアプリ体験

### 3. **iOS版** (/wisbee-ios/)
- **状態**: 開発中
- **モデル**: qwen3-abliterated:0.6b（ローカル実行）
- **フレームワーク**: SwiftUI + SpeziLLM
- **配布**: Xcode経由（TestFlight準備中）

### 4. **その他のデバイス**

#### Android
- **対応策**: Web版で対応（PWA化可能）
- **追加開発**: React Native版を検討

#### Windows/Linux
- **対応策**: 
  1. Web版で即座に利用可能
  2. Electron版を作成（macOS版を流用）

#### タブレット（iPad/Android）
- **iPad**: iOS版が動作可能
- **Android**: Web版で対応

## 🚀 スマートサーバー機能

新しい `smart-server.py` の特徴：
1. 自動ポート検出（8888 → 7777 → 9999 → ...）
2. ポート使用中の自動フォールバック
3. 現在のポートを `.current_port` ファイルに保存
4. 複数インスタンスの同時実行対応

## 📝 推奨アクション

1. **即座に実施**
   - smart-server.py を使用してポート衝突を回避
   - Web版をPWA対応にしてモバイル体験を向上

2. **短期計画**
   - iOS版のTestFlight配布
   - Windows/Linux向けElectron版作成

3. **中長期計画**
   - Android向けReact Native版開発
   - 統一API/バックエンドサービス構築