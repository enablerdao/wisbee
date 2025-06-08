# App Store提出 - 詳細手順

## 📱 必要な準備

### 1. Apple Developer Accountの設定
1. https://developer.apple.com/account/ にログイン
2. Certificates, Identifiers & Profiles → Identifiers → 「+」
3. App IDsを選択 → Continue
4. App → Continue
5. 入力:
   - Description: Wisbee Chat
   - Bundle ID: Explicit → com.wisbee.chat
   - Capabilities: 必要なものをチェック
6. Register

### 2. 証明書の作成（Xcodeで）
1. Xcode → Settings → Accounts
2. Apple IDを選択 → Manage Certificates
3. 「+」ボタン → 以下を作成:
   - Apple Development
   - Apple Distribution

### 3. プロビジョニングプロファイル
1. developer.apple.com → Profiles → 「+」
2. Mac App Store → Mac App Store
3. App ID: com.wisbee.chat を選択
4. 証明書を選択
5. Profile Nameを入力: Wisbee App Store
6. Generate → Download

## 🛠️ Xcodeプロジェクトの作成（推奨）

Electron-builderではなく、Xcodeを使った方が確実です：

### 1. 新規プロジェクト作成
```bash
# Xcodeで新規プロジェクト
# macOS → App を選択
# Product Name: Wisbee
# Bundle Identifier: com.wisbee.chat
# Language: Swift (UIはElectronなのでダミー)
```

### 2. Electronアプリを組み込む
1. プロジェクトにElectronアプリをコピー
2. Build Phases → Copy Bundle Resources に追加
3. Info.plist を編集

### 3. Entitlementsファイル
Xcode内で作成:
- File → New → File → Resource → Property List
- 名前: Wisbee.entitlements
- 内容:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>com.apple.security.app-sandbox</key>
    <true/>
    <key>com.apple.security.network.client</key>
    <true/>
    <key>com.apple.security.files.user-selected.read-write</key>
    <true/>
    <key>com.apple.security.files.downloads.read-write</key>
    <true/>
</dict>
</plist>
```

## 🚀 ビルドと提出

### 1. Xcodeでアーカイブ
1. Product → Archive
2. Archiveが完成したら、Distributeボタン
3. App Store Connect を選択
4. Upload を選択
5. 自動的に署名とアップロード

### 2. App Store Connectで設定
1. https://appstoreconnect.apple.com/
2. アプリ情報を入力
3. ビルドを選択
4. 審査に提出

## ⚠️ 重要な注意点

### Sandbox制限への対応
App StoreアプリはSandbox内で動作するため：

1. **localhost接続の問題**
   - 解決策: Network Extensionを使用
   - または: XPC Serviceでプロキシ

2. **外部プロセス起動の制限**
   - Pythonスクリプトは実行できない
   - Node.jsサーバーに変更済み

3. **Ollamaとの通信**
   - App Groups を使用
   - または: URLスキームで通信

### 推奨される実装変更

```javascript
// App Store版用の通信方法
if (process.mas) { // Mac App Store build
    // URLスキームを使用
    const ollamaURL = 'ollama://api/generate';
    // または XPC Service経由
} else {
    // 通常のHTTP通信
    const ollamaURL = 'http://localhost:11434/api/generate';
}
```

## 📝 審査対策チェックリスト

- [ ] Ollamaの説明を明確に記載
- [ ] 初回起動時のセットアップガイド
- [ ] エラー時の適切なメッセージ
- [ ] プライバシーポリシーURL
- [ ] サポートURL
- [ ] 年齢制限: 4+
- [ ] カテゴリ: Developer Tools
- [ ] 著作権表記

## 🔧 トラブルシューティング

### 証明書エラーの場合
```bash
# キーチェーンを確認
security find-identity -v -p codesigning

# 証明書をリセット
rm -rf ~/Library/MobileDevice/Provisioning\ Profiles/
```

### ビルドエラーの場合
1. Xcodeでクリーンビルド: Cmd+Shift+K
2. DerivedData削除: ~/Library/Developer/Xcode/DerivedData
3. 証明書の再作成

### 審査リジェクトの場合
- ガイドライン 2.1: アプリの完成度
  → セットアップガイドを改善
- ガイドライン 4.2.3: 最小機能要件
  → Ollama無しでも一部機能を提供
- ガイドライン 5.1.1: データ収集とストレージ
  → プライバシーポリシーを詳細に