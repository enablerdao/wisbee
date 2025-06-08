# 🎉 Wisbee Vercel自動デプロイ設定完了ガイド

## ✅ 完了した設定

### 1. GitHub Actions設定
- ✅ 本番環境自動デプロイ (mainブランチ)
- ✅ プレビュー環境自動デプロイ (プルリクエスト)
- ✅ デプロイ通知の自動化

### 2. Vercel設定
- ✅ vercel.json設定ファイル
- ✅ Python API関数
- ✅ セキュリティヘッダー
- ✅ ドメイン設定準備

### 3. プロジェクト情報
- **プロジェクトID**: `prj_7Fo7DbVT6aYmvnqzxLonv2IwBtgx`
- **組織ID**: `team_0Iqka3UC6OsMEB9jPmrPmyNh`
- **リポジトリ**: https://github.com/enablerdao/wisbee
- **本番URL**: https://wisbee.vercel.app

## 🔧 残りの手動設定

### A. Vercelトークン生成
1. https://vercel.com/account/tokens を開く
2. 'Create' → Token Name: 'Wisbee Auto Deploy'
3. Scope: Full Access → 'Create'

### B. GitHubシークレット設定
1. https://github.com/enablerdao/wisbee/settings/secrets/actions
2. 以下の3つを追加:
   - `VERCEL_TOKEN`: [生成したトークン]
   - `VERCEL_ORG_ID`: `team_0Iqka3UC6OsMEB9jPmrPmyNh`
   - `VERCEL_PROJECT_ID`: `prj_7Fo7DbVT6aYmvnqzxLonv2IwBtgx`

### C. DNS設定 (wisbee.ai)
1. https://dash.cloudflare.com → wisbee.ai → DNS
2. CNAMEレコード追加:
   - `@` → `cname.vercel-dns.com` (Proxied)
   - `www` → `cname.vercel-dns.com` (Proxied)

## 🚀 設定完了後の動作

### 自動デプロイ
- **mainブランチへのpush** → 本番環境に自動デプロイ
- **プルリクエスト作成/更新** → プレビュー環境に自動デプロイ
- **デプロイ完了** → GitHubにコメント通知

### アクセスURL
- **本番環境**: https://wisbee.vercel.app
- **カスタムドメイン**: https://wisbee.ai (DNS設定後)
- **www**: https://www.wisbee.ai (DNS設定後)

## 🔍 確認方法

### 設定確認
```bash
# 1. GitHubシークレット確認
# https://github.com/enablerdao/wisbee/settings/secrets/actions

# 2. DNS伝播確認
dig wisbee.ai
dig www.wisbee.ai

# 3. サイトアクセス確認
curl -I https://wisbee.ai
curl -I https://www.wisbee.ai
```

### デプロイテスト
```bash
# リポジトリ更新でデプロイをテスト
git add .
git commit -m "Test auto deployment"
git push origin main

# GitHub Actionsの実行確認
# https://github.com/enablerdao/wisbee/actions
```

## 🎯 完了チェックリスト

- [ ] Vercelトークン生成完了
- [ ] GitHubシークレット3つ設定完了
- [ ] CloudflareでCNAMEレコード2つ追加完了
- [ ] https://wisbee.ai アクセス確認
- [ ] GitHub Actionsでデプロイテスト確認

## 🆘 トラブルシューティング

### DNS設定が反映されない
- 伝播に最大48時間かかる場合があります
- `dig wisbee.ai`でCNAMEレコードを確認

### GitHub Actionsが失敗する
- GitHubシークレットが正しく設定されているか確認
- Vercelトークンの権限がFull Accessか確認

### Vercelデプロイエラー
- vercel.json設定ファイルの構文確認
- api/index.py ファイルの存在確認

---

**すべて完了すると、wisbee.aiで美しいAIチャットアプリにアクセスできます！**