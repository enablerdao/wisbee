# 🚀 Wisbee リリース前チェックリスト

## 🔴 緊急・必須項目

### 1. **アプリの動作確認**
- [ ] Wisbeeアプリが正常に起動する
- [ ] http://localhost:8899 でチャットが動作
- [ ] http://localhost:8899/download でダウンロードページ表示
- [ ] モデルの切り替えができる
- [ ] チャット機能が正常に動作
- [ ] 美しいUIデザインが表示される

### 2. **GitHub リポジトリ準備**
- [ ] enablerdao/wisbee リポジトリ作成
- [ ] README.md に完全な説明
- [ ] LICENSE ファイル
- [ ] リリースv1.0.0タグ作成
- [ ] 実際のバイナリファイルをアップロード
- [ ] デモGIF、スクリーンショット追加

### 3. **ダウンロードページ確認**
- [ ] wisbee.github.io が表示される
- [ ] ダウンロードリンクが実際に動作
- [ ] SEOメタタグが正しい
- [ ] モバイル表示が正常

### 4. **デモアセット生成**
```bash
cd /Users/yuki/bench-llm/wisbee
python3 create_demo_assets.py
```
- [ ] OGP画像生成成功
- [ ] デモGIF生成成功
- [ ] 比較画像生成成功
- [ ] バナー画像生成成功

## 🟡 重要項目

### 5. **連絡先・サポート体制**
- [ ] contact@enablerdao.org メール設定
- [ ] support@enablerdao.org メール設定  
- [ ] press@enablerdao.org メール設定
- [ ] GitHub Issues対応体制
- [ ] Discord/Slackコミュニティ準備

### 6. **分析・追跡設定**
- [ ] Google Analytics設定
- [ ] GitHub Insights確認
- [ ] ダウンロード数カウンター
- [ ] ソーシャルメディア分析

### 7. **プレスリリース準備**
- [ ] 6月10日版の最終校正
- [ ] 6月22日版の日付調整
- [ ] 配信先リスト作成
- [ ] メディアキット準備

## 🟢 推奨項目

### 8. **バックアップ・リカバリ**
- [ ] 重要ファイルのバックアップ
- [ ] GitHub Private リポジトリでのミラー
- [ ] ドメイン設定のバックアップ
- [ ] 緊急時の対応マニュアル

### 9. **追加コンテンツ**
- [ ] FAQ ページ作成
- [ ] プライバシーポリシー
- [ ] 利用規約
- [ ] 開発ロードマップ

## ⚠️ 現在の問題点と解決策

### 問題1: アプリが起動していない
**解決策**: 
```bash
cd /Users/yuki/bench-llm/wisbee-mac
pkill -f electron
pkill -f ollama-webui-server
npm start
```

### 問題2: 実際のバイナリがない
**解決策**:
```bash
cd /Users/yuki/bench-llm/wisbee-mac
npm run dist-mac  # macOS版ビルド
npm run dist-win  # Windows版ビルド
npm run dist-linux # Linux版ビルド
```

### 問題3: GitHub リリースページが空
**解決策**:
1. GitHubでv1.0.0タグ作成
2. ビルドしたバイナリをアップロード
3. リリースノート追加

## 📝 実行コマンド集

### アプリ起動
```bash
cd /Users/yuki/bench-llm/wisbee-mac
npm start
```

### デモアセット生成
```bash
cd /Users/yuki/bench-llm/wisbee
python3 create_demo_assets.py
```

### バイナリビルド
```bash
cd /Users/yuki/bench-llm/wisbee-mac
npm run dist-all
```

### サイト更新
```bash
cd /Users/yuki/bench-llm/wisbee-github-io
git add .
git commit -m "Update for release"
git push
```

## 🎯 成功指標

### 初日目標
- [ ] ダウンロード数: 1,000件
- [ ] GitHub Stars: 100
- [ ] Twitter エンゲージメント: 50RT以上

### 1週間目標  
- [ ] ダウンロード数: 10,000件
- [ ] GitHub Stars: 500
- [ ] メディア掲載: 3件以上

### 1ヶ月目標
- [ ] ダウンロード数: 100,000件
- [ ] GitHub Stars: 2,000
- [ ] 企業導入: 10社

## 🚨 緊急対応計画

### サーバーダウン時
1. GitHub Pages の問題確認
2. Cloudflare経由での緊急配信
3. 代替ダウンロードサイト起動

### 大量トラフィック時
1. CDN設定の確認
2. 帯域制限の調整
3. ミラーサイトの準備

### バグ発見時
1. 緊急パッチの準備
2. ユーザーへの周知
3. 修正版の迅速リリース