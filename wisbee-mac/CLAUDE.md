# CLAUDE.md - Wisbee Mac App

このファイルは、Claude Code (claude.ai/code) がこのリポジトリで作業する際のガイダンスを提供します。

## プロジェクト概要

Wisbee Mac App - ChatGPTより安全・無料・オープンなAIチャットアプリケーション。完全ローカルで動作し、美しいUIとアニメーション効果を備えています。

## ポート設定

- **アプリケーションポート**: `8899`
- **Ollama APIポート**: `11434` (Ollamaのデフォルト)

## URL構成

- **メインチャット**: http://localhost:8899 → `/chat.html`
- **ダウンロードページ**: http://localhost:8899/download → `../wisbee-github-io/index.html`
- **設定API**: http://localhost:8899/config.json
- **Ollama API プロキシ**: http://localhost:8899/api/*

## 最新のデザインアップデート

### chat.html の変更点
- 🐝 ロゴアイコンをWisbeeブランドに変更
- 「ChatGPTより安全・無料・オープンなAI」タグライン追加
- アニメーション背景効果 (rotating gradient)
- 浮遊アニメーション効果 (logo float animation)
- メッセージカードのホバーエフェクト強化
- グラデーション送信ボタン
- Noto Sans JP フォント対応

## ファイル構成

```
wisbee-mac/
├── chat.html           # メインチャットUI (新デザイン適用済み)
├── ollama-webui-server.py  # Pythonサーバー (ルーティング設定済み)
├── main.js            # Electronメインプロセス
├── package.json       # Node.js設定
└── README.md          # ドキュメント (更新済み)
```

## 開発時の注意点

1. **ポートの競合**
   - 起動前に必ずポート8899が空いていることを確認
   - `lsof -ti:8899 | xargs kill -9` で強制終了可能

2. **キャッシュの問題**
   - デザイン変更が反映されない場合は Cmd+R でリロード
   - Electronのキャッシュクリア: Cmd+Shift+R

3. **プロセス管理**
   - Electronアプリとollama-webui-server.pyが同時に起動
   - 終了時は両方のプロセスを確実に停止

4. **ダウンロードページ**
   - `/download` へのアクセスは `../wisbee-github-io/index.html` を表示
   - 相対パスで隣のディレクトリを参照

## コマンド

```bash
# 開発環境の起動
npm start

# ビルド
npm run build-mac

# プロセスの強制終了
pkill -9 -f electron
pkill -9 -f ollama-webui-server
```

## トラブルシューティング

- **デザインが古いまま**: Electronのキャッシュをクリア、またはアプリを完全に再起動
- **ポートエラー**: 既存のプロセスを終了してから再起動
- **ダウンロードページ404**: wisbee-github-ioディレクトリの存在を確認