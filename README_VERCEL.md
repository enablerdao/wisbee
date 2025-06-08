# Wisbee Vercel Deployment Guide

このガイドでは、Wisbee製品サイトをVercelにデプロイする方法を説明します。

## 🚀 クイックデプロイ

### 前提条件
- Node.js 16以降がインストールされていること
- GitHubアカウント（推奨）
- Vercelアカウント

### 1. 自動デプロイ（推奨）
```bash
# リポジトリをクローン
git clone https://github.com/enablerdao/wisbee.git
cd wisbee

# デプロイスクリプトを実行
./deploy.sh
```

### 2. 手動デプロイ
```bash
# Vercel CLIをインストール
npm install -g vercel

# Vercelにログイン
vercel login

# プロジェクトをデプロイ
vercel --prod
```

## 📁 プロジェクト構成

```
wisbee/
├── index.html           # メインランディングページ
├── vercel.json          # Vercel設定ファイル
├── package.json         # プロジェクト設定
├── api/
│   └── index.py        # デモAPI（Python）
├── assets/             # 画像・アイコン
├── deploy.sh           # デプロイスクリプト
└── README_VERCEL.md    # このファイル
```

## ⚙️ Vercel設定説明

### vercel.json
- **ランタイム**: Python 3.11 for API functions
- **ルーティング**: SPAルーティング設定
- **セキュリティヘッダー**: XSS、フレーミング防止
- **静的ファイル**: HTML、CSS、JSの最適化

### API機能
- `/api/health` - ヘルスチェック
- `/api/tags` - デモモデル一覧
- `/api/generate` - デモAI応答

## 🌐 カスタムドメイン設定

1. Vercelダッシュボードにアクセス
2. プロジェクトを選択
3. Settings > Domains
4. カスタムドメインを追加
5. DNSレコードを設定

### 推奨ドメイン構成
```
wisbee.com          → プロダクションサイト
demo.wisbee.com     → デモ環境
staging.wisbee.com  → ステージング環境
```

## 🔧 環境変数

本プロジェクトは静的サイトのため、特別な環境変数は不要です。
APIは純粋にデモ目的のため、外部サービスとの連携はありません。

## 📊 パフォーマンス最適化

Vercelで自動的に適用される最適化:
- **画像最適化**: 自動WebP変換
- **CDN配信**: 全世界エッジロケーション
- **圧縮**: Gzip/Brotli圧縮
- **キャッシュ**: 静的アセットの自動キャッシュ

## 🚨 トラブルシューティング

### デプロイエラー
```bash
# プロジェクトを再デプロイ
vercel --prod --force

# ログを確認
vercel logs
```

### ドメインエラー
1. DNS設定を確認
2. VercelのDNSレコードが正しく設定されているか確認
3. 伝播に最大48時間かかる場合があります

### API エラー
- `/api/health` エンドポイントでAPI状態を確認
- Python関数のログをVercelダッシュボードで確認

## 📈 監視・分析

### Vercel Analytics
```bash
# Analytics有効化
vercel env add VERCEL_ANALYTICS_ID your-analytics-id
```

### 推奨監視ツール
- **Vercel Analytics**: ページビュー、パフォーマンス
- **Google Analytics**: 詳細なユーザー行動分析
- **Vercel Monitoring**: エラートラッキング

## 🔄 継続的デプロイ

### GitHub連携（推奨）
1. Vercelダッシュボードで「Import Git Repository」
2. GitHubリポジトリを選択
3. 自動ビルド設定を確認
4. mainブランチへのプッシュで自動デプロイ

### 手動デプロイ
```bash
# 変更をコミット
git add .
git commit -m "Update site content"

# Vercelにデプロイ
vercel --prod
```

## 📞 サポート

- **Vercel問題**: [Vercel Support](https://vercel.com/support)
- **Wisbee問題**: [GitHub Issues](https://github.com/enablerdao/wisbee/issues)
- **一般的な質問**: [Discussions](https://github.com/enablerdao/wisbee/discussions)

## 📄 ライセンス

このプロジェクトはMITライセンスの下で提供されています。詳細は[LICENSE](LICENSE)ファイルを参照してください。